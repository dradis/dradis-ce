require 'rails_helper'

describe "Notes API" do

  include_context "project scoped API"
  include_context "https"

  let(:node) { create(:node, project: current_project) }

  context "as unauthenticated user" do
    [
      ['get', '/api/nodes/1/notes/'],
      ['get', '/api/nodes/1/notes/1'],
      ['post', '/api/nodes/1/notes/'],
      ['put', '/api/nodes/1/notes/1'],
      ['patch', '/api/nodes/1/notes/1'],
      ['delete', '/api/nodes/1/notes/1'],
    ].each do |verb, url|
      describe "#{verb.upcase} #{url}" do
        it 'throws 401' do
          send(verb, url, params: {}, env: @env)
          expect(response.status).to eq 401
        end
      end
    end
  end

  context "as authauthorized user" do
    include_context "authorized API user"

    let(:category) { create(:category) }

    describe "GET /api/nodes/:node_id/notes" do
      before do
        @notes = [
          create(:note, node: node, text: "#[Title]#\nNote 0\n\n#[foo]#\nbar"),
          create(:note, node: node, text: "#[Title]#\nNote 1\n\n#[uno]#\none"),
          create(:note, node: node, text: "#[Title]#\nNote 2\n\n#[dos]#\ntwo"),
        ]
        @other_note = create(
          :note, node: create(:node, project: current_project), text: "#[Title]#\nOther Note"
        )
        get "/api/nodes/#{node.id}/notes", env: @env
      end

      let(:retrieved_notes) { JSON.parse(response.body) }

      it "responds with HTTP code 200" do
        expect(response.status).to eq(200)
      end

      it "retrieves all the notes for the given node" do
        expect(retrieved_notes.count).to eq 3
        retrieved_titles = retrieved_notes.map{ |json| json['title'] }
        expect(retrieved_titles).to match_array(@notes.map(&:title))
      end

      it "includes fields" do
        note_0 = retrieved_notes.detect { |n| n["title"] == "Note 0" }
        note_1 = retrieved_notes.detect { |n| n["title"] == "Note 1" }
        note_2 = retrieved_notes.detect { |n| n["title"] == "Note 2" }

        expect(note_0["fields"].keys).to match_array %w[Title foo]
        expect(note_0["fields"]["foo"]).to eq "bar"
        expect(note_1["fields"].keys).to match_array %w[Title uno]
        expect(note_1["fields"]["uno"]).to eq "one"
        expect(note_2["fields"].keys).to match_array %w[Title dos]
        expect(note_2["fields"]["dos"]).to eq "two"
      end

      it "doesn't return notes from other nodes" do
        retrieved_ids = retrieved_notes.map { |n| n["id"] }
        expect(retrieved_ids).not_to include @other_note.id
      end
    end

    describe "GET /api/nodes/:node_id/notes/:id" do
      before do
        @note = node.notes.create!(
          text:     "#[Title]#\nMy note\n#[foo]#\nbar\n#[fizz]#\nbuzz",
          category: category,
        )
        get "/api/nodes/#{node.id}/notes/#{@note.id}", env: @env
      end

      it "responds with HTTP code 200" do
        expect(response.status).to eq 200
      end

      it "returns JSON information about the note" do
        retrieved_note = JSON.parse(response.body)
        expect(retrieved_note["id"]).to eq @note.id
        expect(retrieved_note["title"]).to eq "My note"
        expect(retrieved_note["category_id"]).to eq category.id
        expect(retrieved_note["fields"].keys).to match_array(
          %w[foo fizz Title]
        )
        expect(retrieved_note["fields"]["foo"]).to eq "bar"
        expect(retrieved_note["fields"]["fizz"]).to eq "buzz"
      end
    end

    describe "POST /api/nodes/:node_id/notes" do
      let(:url) { "/api/nodes/#{node.id}/notes" }
      let(:post_note) { post url, params: params.to_json, env: @env }

      context "when content_type header = application/json" do
        include_context "content_type: application/json"

        context "with params for a valid note" do
          let(:params) { { note: { text: "New note" } } }

          it "responds with HTTP code 201" do
            post_note
            expect(response.status).to eq 201
          end

          let(:submit_form) { post_note }
          include_examples 'creates an Activity', :create, Note
          include_examples 'sets the whodunnit', :create, Note

          context "specifying a category" do
            before { params[:note][:category_id] = category.id }

            it "creates a note with the given node & category" do
              expect{post_note}.to change{node.notes.count}.by(1)
              note = node.notes.last
              expect(note.category).to eq category
            end

            it "returns the attributes of the new note as JSON" do
              post_note
              retrieved_note = JSON.parse(response.body)
              params[:note].each do |attr, value|
                expect(retrieved_note[attr.to_s]).to eq value
              end
              expect(response.location).to eq(
                dradis_api.node_note_path(node.id, retrieved_note['id'])
              )
            end
          end

          context "and category is not specified" do
            it "creates a note with the given node & default category" do
              expect{post_note}.to change{node.notes.count}.by(1)
              expect(node.notes.last.category).to eq Category.default
            end
          end
        end

        context "with params for an invalid note" do
          let(:params) { { note: { text: "a"*65536 } } } # too long

          it "responds with HTTP code 422" do
            post_note
            expect(response.status).to eq 422
          end

          it "doesn't create a note" do
            expect{post_note}.not_to change{Note.count}
          end
        end

        context "when no :note param is sent" do
          let(:params) { {} }

          it "doesn't create a note" do
            expect{post_note}.not_to change{Note.count}
          end

          it "responds with HTTP code 422" do
            post_note
            expect(response.status).to eq(422)
          end
        end

        context "when invalid JSON is sent" do
          it "responds with HTTP code 400" do
            json_payload = '{"note":{"label":"A malformed label", , }}'
            post url, params: json_payload, env: @env
            expect(response.status).to eq(400)
          end
        end
      end

      context "when JSON is not sent" do
        it "responds with HTTP code 415" do
          params = { note: { } }
          post url, params: params, env: @env
          expect(response.status).to eq(415)
        end
      end
    end

    describe "PUT /api/nodes/:node_id/notes/:id" do
      let(:note) do
        create(:note, node: node, text: "My text")
      end

      let(:url) { "/api/nodes/#{node.id}/notes/#{note.id}" }
      let(:put_note) { put url, params: params.to_json, env: @env }

      context "when content_type header = application/json" do
        include_context "content_type: application/json"

        context "with params for a valid note" do
          let(:params) { { note: { text: "New text" } } }

          it "responds with HTTP code 200" do
            put_note
            expect(response.status).to eq 200
          end

          it "updates the note" do
            put_note
            expect(note.reload.text).to eq "New text"
          end

          let(:submit_form) { put_note }
          let(:model) { note }
          include_examples 'creates an Activity', :update
          include_examples 'sets the whodunnit', :update

          it "returns the attributes of the updated note as JSON" do
            put_note
            retrieved_note = JSON.parse(response.body)
            expect(retrieved_note["text"]).to eq "New text"
          end
        end

        context "with params for an invalid note" do
          let(:params) { { note: { text: "a"*65536 } } } # too long

          it "responds with HTTP code 422" do
            put_note
            expect(response.status).to eq 422
          end

          it "doesn't update the note" do
            expect{put_note}.not_to change{note.reload.attributes}
          end
        end

        context "when no :note param is sent" do
          let(:params) { {} }

          it "doesn't update the note" do
            expect{put_note}.not_to change{note.reload.attributes}
          end

          it "responds with HTTP code 422" do
            put_note
            expect(response.status).to eq 422
          end
        end

        context "when invalid JSON is sent" do
          it "responds with HTTP code 400" do
            json_payload = '{"note":{"label":"A malformed label", , }}'
            put url, params: json_payload, env: @env
            expect(response.status).to eq(400)
          end
        end
      end

      context "when JSON is not sent" do
        let(:params) { { note: { text: "New Note" } } }

        it "responds with HTTP code 415" do
          expect{put url, params: params, env: @env}.not_to change{note.reload.attributes}
          expect(response.status).to eq 415
        end
      end
    end

    describe "DELETE /api/nodes/:node_id/notes/:id" do
      let(:note) { create(:note, node: node, text: "My Note") }

      let(:delete_note) do
        delete "/api/nodes/#{node.id}/notes/#{note.id}", env: @env
      end

      it "deletes the note" do
        note_id = note.id
        delete_note
        expect(Note.find_by_id(note_id)).to be_nil
      end

      it "responds with error code 200" do
        delete_note
        expect(response.status).to eq(200)
      end

      let(:submit_form) { delete_note }
      let(:model) { note }
      include_examples "creates an Activity", :destroy

      it "returns JSON with a success message" do
        delete_note
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["message"]).to eq\
          "Resource deleted successfully"
      end
    end
  end
end
