require 'rails_helper'

describe 'Lists API' do

  include_context 'project scoped API'
  include_context 'https'

  let(:board) { create(:board, project: current_project) }

  context 'as unauthenticated user' do
    [
      ['get', '/api/boards/1/lists'],
      ['get', '/api/boards/1/lists/1'],
      ['post', '/api/boards/1/lists'],
      ['put', '/api/boards/1/lists/1'],
      ['patch', '/api/boards/1/lists/1'],
      ['delete', '/api/boards/1/lists/1'],
    ].each do |verb, url|
      describe "#{verb.upcase} #{url}" do
        it 'throws 401' do
          send(verb, url, params: {}, env: @env)
          expect(response.status).to eq 401
        end
      end
    end
  end

  context 'as authorized user' do
    include_context 'authorized API user'

    describe 'GET /api/boards/:board_id/lists/:list_id/cards', pending: true do
      before do
        @cards = [
          Card.create!(list: list, description: "#[a]#\nA", name: 'Card A'),
          Card.create!(list: list, description: "#[b]#\nB", name: 'Card B'),
          Card.create!(list: list, description: "#[c]#\nC", name: 'Card C'),
        ] + create_list(:card, 30, list: list)
        @other_card = create(:card, list: create(:list, board: board))
        get "/api/boards/#{board.id}/lists/#{list.id}/cards?#{params}", env: @env
      end

      let(:retrieved_cards) { JSON.parse(response.body) }

      context 'without params' do
        let(:params) { '' }

        it 'responds with HTTP code 200' do
          expect(response.status).to eq(200)
        end

        it 'retrieves all the cards for the given list' do
          expect(retrieved_cards.count).to eq 33
          card_names = retrieved_cards.map { |json| json['name'] }
          expect(card_names).to match_array @cards.map(&:name)
        end

        it 'returns JSON data about the cards\'s fields' do
          ev_0 = retrieved_cards.find { |n| n['id'] == @cards[0].id }
          ev_1 = retrieved_cards.find { |n| n['id'] == @cards[1].id }
          ev_2 = retrieved_cards.find { |n| n['id'] == @cards[2].id }

          expect(ev_0['fields'].keys).to \
            match_array (@cards[0].local_fields.keys << 'a')
          expect(ev_0['fields']['a']).to eq 'A'

          expect(ev_1['fields'].keys).to \
            match_array (@cards[2].local_fields.keys << 'b')
          expect(ev_1['fields']['b']).to eq 'B'

          expect(ev_2['fields'].keys).to \
            match_array (@cards[2].local_fields.keys << 'c')
          expect(ev_2['fields']['c']).to eq 'C'
        end

        it 'doesn\'t return cards from other lists' do
          retrieved_ids = retrieved_cards.map { |n| n['id'] }
          expect(retrieved_ids).not_to include @other_card.id
        end
      end

      context 'with params' do
        let(:params) { 'page=2' }

        it 'returns the paginated evidence' do
          expect(retrieved_lists.count).to eq 8
        end
      end
    end

    describe 'GET /api/boards/:board_id/lists/:list_id/cards/:id', pending: true do
      before do
        @card = list.cards.create!(
          description: "#[foo]#\nbar\n#[fizz]#\nbuzz",
          name: 'My rspec card',
        )
        get "/api/boards/#{board.id}/lists/#{list.id}/cards/#{@card.id}", env: @env
      end

      it 'responds with HTTP code 200' do
        expect(response.status).to eq 200
      end

      it 'returns JSON information about the card' do
        retrieved_card = JSON.parse(response.body)
        expect(retrieved_card['id']).to eq @card.id
        expect(retrieved_card['name']).to eq @card.name
        expect(retrieved_card['fields'].keys).to match_array(
          @card.local_fields.keys + %w(fizz foo)
        )
        expect(retrieved_card['fields']['foo']).to eq 'bar'
        expect(retrieved_card['fields']['fizz']).to eq 'buzz'
      end
    end

    describe 'POST /api/boards/:board_id/lists' do
      let(:url) { "/api/boards/#{board.id}/lists" }
      let(:post_list) { post url, params: params.to_json, env: @env }

      context 'when content_type header = application/json' do
        include_context 'content_type: application/json'

        context 'with params for a valid list' do
          let(:params) { { list: { name: 'New name' } } }

          it 'responds with HTTP code 201' do
            post_list
            expect(response.status).to eq 201
          end

          it 'creates an list' do
            expect { post_list }.to change { board.lists.count }
            new_list = board.lists.last
            expect(new_list.name).to eq 'New name'
          end

          let(:submit_form) { post_list }
          include_examples 'creates an Activity', :create, List
        end

        context 'with params for an invalid list' do
          let(:params) { { list: { } } } # no name

          it 'responds with HTTP code 422' do
            post_list
            expect(response.status).to eq 422
          end

          it "doesn't create a list" do
            expect { post_list }.not_to change { List.count }
          end
        end

        context 'when no :list param is sent' do
          let(:params) { {} }

          it "doesn't create an list" do
            expect { post_list }.not_to change { List.count }
          end

          it 'responds with HTTP code 422' do
            post_list
            expect(response.status).to eq(422)
          end
        end

        context 'when invalid JSON is sent' do
          it 'responds with HTTP code 400' do
            json_payload = '{"list":{"name":"A malformed name", , }}'
            post url, params: json_payload, env: @env
            expect(response.status).to eq(400)
          end
        end
      end

      context 'when JSON is not sent' do
        it 'responds with HTTP code 415' do
          params = { list: {} }
          post url, params: params, env: @env
          expect(response.status).to eq(415)
        end
      end
    end

    describe 'PUT /api/boards/:board_id/lists/:id' do
      let(:list) { create(:list, board: board) }
      let(:url) { "/api/boards/#{board.id}/lists/#{list.id}" }
      let(:put_list) { put url, params: params.to_json, env: @env }

      context 'when content_type header = application/json' do
        include_context 'content_type: application/json'

        context 'with params for a valid list' do
          let(:params) { { list: { name: 'New name' } } }

          it 'responds with HTTP code 200' do
            put_list
            expect(response.status).to eq 200
          end

          it 'updates the list' do
            put_list
            expect(list.reload.name).to eq 'New name'
          end

          it 'returns the attributes of the updated list as JSON' do
            put_list
            retrieved_list = JSON.parse(response.body)
            expect(retrieved_list['name']).to eq 'New name'
          end

          let(:submit_form) { put_list }
          let(:model) { list }
          include_examples 'creates an Activity', :update
        end

        context 'with params for an invalid list' do
          let(:params) { { list: { name: 'a' * 65536 } } } # too long

          it 'responds with HTTP code 422' do
            put_list
            expect(response.status).to eq 422
          end

          it "doesn't update the list" do
            expect { put_list }.not_to change { list.reload.attributes }
          end
        end

        context 'when no :list param is sent' do
          let(:params) { {} }

          it "doesn't update the list" do
            expect { put_list }.not_to change { list.reload.attributes }
          end

          it 'responds with HTTP code 422' do
            put_list
            expect(response.status).to eq 422
          end
        end

        context 'when invalid JSON is sent' do
          it 'responds with HTTP code 400' do
            json_payload = '{"list":{"name":"A malformed name", , }}'
            put url, params: json_payload, env: @env
            expect(response.status).to eq(400)
          end
        end
      end

      context 'when JSON is not sent' do
        let(:params) { { list: { name: 'New List' } } }

        it 'responds with HTTP code 415' do
          expect { put url, params: params, env: @env }.not_to change { list.reload.attributes }
          expect(response.status).to eq 415
        end
      end
    end

    describe 'DELETE /api/boards/:board_id/lists/:id' do
      let(:list) { create(:list, board: board) }

      let(:delete_list) do
        delete "/api/boards/#{board.id}/lists/#{list.id}", env: @env
      end

      it 'deletes the list' do
        list_id = list.id
        delete_list
        expect(List.find_by_id(list_id)).to be_nil
      end

      it 'responds with error code 200' do
        delete_list
        expect(response.status).to eq(200)
      end

      it 'returns JSON with a success message' do
        delete_list
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['message']).to eq\
          'Resource deleted successfully'
      end

      let(:submit_form) { delete_list }
      let(:model) { list }
      include_examples 'creates an Activity', :destroy
    end
  end
end
