require 'rails_helper'

describe "note pages" do
  subject { page }

  include ActivityMacros

  before do
    # avoid messing around with any existing templates:
    allow(NoteTemplate).to receive(:pwd).and_return(Pathname.new('tmp/templates/notes'))
    FileUtils.mkdir_p(Rails.root.join("tmp","templates","notes"))
    login_to_project_as_user
    @node    = create(:node)
  end

  after(:all) do
    FileUtils.rm_rf('tmp/templates')
  end

  example 'show page with wrong Node ID in URL' do
    node       = create(:node)
    note       = create(:note, node: node)
    wrong_node = create(:node)
    expect do
      visit project_node_note_path(current_project, wrong_node, note)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe "show page" do
    before do
      text = "#[Title]#\nMy note\n\n#[Description]#\nMy description"
      @note = create(:note, node: @node, text: text)
      create_activities
      visit project_node_note_path(current_project, @node, @note)
    end

    let(:create_activities) { nil }

    it "shows the note's contents" do
      should have_selector "h4", text: "Title"
      should have_selector "p",  text: "My note"
      should have_selector "h4", text: "Description"
      should have_selector "p",  text: "My description"
    end

    let(:trackable) { @note }
    it_behaves_like "a page with an activity feed"

    describe "clicking 'delete'" do
      let(:submit_form) { within('.note-text-inner') { click_link "Delete" } }

      it "deletes the note and redirects to the node's page" do
        id = @note.id
        submit_form
        expect(Note.find_by_id(id)).to be_nil
        expect(current_path).to eq project_node_path(@node.project, @node)
      end

      let(:model) { @note }
      include_examples "creates an Activity", :destroy

      include_examples "deleted item is listed in Trash", :note
      include_examples "recover deleted item", :note
      include_examples "recover deleted item without node", :note
    end
  end

  describe "edit page" do
    before do
      @note = create(:note, node: @node, updated_at: 2.seconds.ago)
      visit edit_project_node_note_path(current_project, @node, @note)
    end

    let(:submit_form) { click_button "Update Note" }

    it "has a form to edit the note" do
      should have_field :note_text
      should have_field :note_category_id
    end

    it "uses the full-screen editor plugin" # TODO

    it_behaves_like "a form with a help button"

    # TODO handle the case where a Note has no paperclip versions (legacy data)

    describe "submitting the form with valid information" do
      let(:new_content) { 'New note text' }
      before { fill_in :note_text, with: new_content }

      it "updates the note" do
        submit_form
        expect(@note.reload.text).to eq new_content
      end

      it "shows the updated note" do
        submit_form
        expect(current_path).to eq project_node_note_path(current_project, @node, @note)
        expect(page).to have_content new_content
      end

      let(:model) { @note }
      include_examples "creates an Activity", :update

      let(:column) { :text }
      let(:record) { @note }
      it_behaves_like "a page which handles edit conflicts"
    end

    describe "submitting the form with invalid information" do
      before { fill_in :note_text, with: "a"*65536 }

      # TODO how to handle conflicting edits in this case?

      it "doesn't update the note" do
        expect{submit_form}.not_to change{@note.reload.text}
      end

      include_examples "doesn't create an Activity"

      it "shows the form again with an error message" do
        submit_form
        should have_field :note_text
        should have_selector ".alert.alert-error"
      end
    end
  end


  describe "new page" do
    let(:content) { "This is an example note" }
    let(:path)    { Rails.root.join("tmp", "templates", "notes", "tmpnote.txt") }

    # Create the dummy NoteTemplate:
    before do
      File.write(path, content)
      visit new_project_node_note_path(current_project, @node, params)
    end
    after { File.delete(path) }

    let(:submit_form) { click_button "Create Note" }

    context "when no template is specified" do
      let(:params) { {} }

      it "displays a blank textarea" do
        textarea = find("textarea#note_text")
        expect(textarea.value.strip).to eq ""
      end

      it "uses the textile-editor plugin"

      it_behaves_like "a form with a help button"

      describe "submitting the form with valid information" do
        let(:new_note) { @node.notes.order('created_at ASC').last }

        before do
          # "fill_in :note_text" doesn't work for some reason :(
          find("#note_text").set('This is a note')
        end

        it "creates a new note from the current user" do
          expect{submit_form}.to change{@node.notes.count}.by(1)
          expect(new_note.author).to eq @logged_in_as.email
        end

        it "shows the newly created note" do
          submit_form
          expect(current_path).to eq project_node_note_path(current_project, @node, new_note)
          expect(page).to have_content "This is a note"
        end

        include_examples "creates an Activity", :create, Note
      end

      describe "submitting the form with invalid information" do
        before { fill_in :note_text, with: "a"*65536 }

        it "doesn't create a note" do
          expect{submit_form}.not_to change{Note.count}
        end

        include_examples "doesn't create an Activity"

        it "shows the form again with an error message" do
          submit_form
          should have_field :note_text
          should have_selector ".alert.alert-error"
        end
      end
    end

    context "when a NoteTemplate is specified" do
      let(:params)  { { template: "tmpnote" } }

      it "pre-populates the textarea with the template contents" do
        textarea = find("textarea#note_text")
        expect(textarea.value.strip).to eq content
      end

      it "uses the textile-editor plugin"
    end
  end
end
