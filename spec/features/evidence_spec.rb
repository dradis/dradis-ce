require 'rails_helper'

describe "evidence" do
  subject { page }

  let(:issue_lib) { Node.issue_library }

  before do
    login_to_project_as_user
    @node = create(:node)
    Node.issue_library
  end

  describe "show page" do
    before(:each) do
      e_text    = "#[Foobar]#\nBarfoo\n\n#[Fizzbuzz]#\nBuzzfizz"
      i_text    = "#[Issue Title]#\nIssue info"
      @issue    = create(:issue,    node: @node, text: i_text)
      @evidence = create(:evidence, node: @node, issue: @issue, content: e_text)
      create_activities
      visit project_node_evidence_path(current_project, @node, @evidence)
    end

    let(:create_activities) { nil }

    it "shows information about the Evidence" do
      should have_selector "h4", text: "Foobar"
      should have_selector "p",  text: "Barfoo"
      should have_selector "h4", text: "Fizzbuzz"
      should have_selector "p",  text: "Buzzfizz"
    end

    it "shows information about the evidence's Issue" do
      should have_selector "h4", text: "Issue Title"
      should have_selector "p",  text: "Issue info"
    end

    let(:trackable) { @evidence }
    it_behaves_like "a page with an activity feed"

    describe "clicking 'delete'" do
      let(:submit_form) { within('.note-text-inner') { click_link "Delete" } }
      it "deletes the Evidence" do
        id = @evidence.id
        submit_form
        expect(Evidence.exists?(id)).to be false
      end

      let(:model) { @evidence }
      include_examples "creates an Activity", :destroy

      include_examples "deleted item is listed in Trash", :evidence
      include_examples "recover deleted item", :evidence
      include_examples "recover deleted item without node", :evidence
    end
  end


  describe "edit page" do
    let(:submit_form) { click_button "Update Evidence" }

    before do
      issue = create(:issue, node: issue_lib)
      @evidence = create(:evidence, issue: issue, updated_at: 2.seconds.ago)
      visit edit_project_node_evidence_path(current_project, @node, @evidence)
    end

    it "uses the full-screen editor plugin" # TODO

    it_behaves_like "a form with a help button"

    describe "submitting the form with valid information" do
      let(:new_content) { "new content" }
      before { fill_in :evidence_content, with: new_content }

      it "updates the evidence" do
        submit_form
        expect(@evidence.reload.content).to eq new_content
        expect(current_path).to eq project_node_evidence_path(current_project, @node, @evidence)
      end

      let(:model) { @evidence }
      include_examples "creates an Activity", :update

      let(:record) { @evidence }
      let(:column) { :content }
      it_behaves_like "a page which handles edit conflicts"
    end

    describe "submitting the form with invalid data" do
      before { fill_in :evidence_content, with: "a"*65536 }

      it "doesn't update the evidence" do
        expect{submit_form}.not_to change{@evidence.reload.content}
        expect(page).to have_field :evidence_content
      end

      include_examples "doesn't create an Activity"
    end
  end


  describe "new page" do
    let(:content) { "This is example evidence" }
    let(:tmp_dir) { Rails.root.join("tmp", "templates", "notes") }
    let(:path)    { tmp_dir.join("tmpevidence.txt") }

    let(:submit_form) { click_button "Create Evidence" }

    # Create the dummy NoteTemplate:
    before do
      allow(NoteTemplate).to receive(:pwd) { Pathname.new(tmp_dir) }
      FileUtils.mkdir_p(tmp_dir)
      File.write(path, content)
      @issue_0 = create(:issue, node: issue_lib, text: "#[Title]#\nIssue 0")
      @issue_1 = create(:issue, node: issue_lib, text: "#[Title]#\nIssue 1")
      visit new_project_node_evidence_path(current_project, @node, params)
    end
    # Check the file still exists before trying to delete it, or File.delete
    # will fail noisily (e.g. if the file has been automatically cleaned up by
    # Codeship before the after block runs)
    after { File.delete(path) if File.exists?(path) }

    context "when no template is specified" do
      let(:params) { {} }

      it "displays a blank textarea" do
        textarea = find("textarea#evidence_content")
        expect(textarea.value.strip).to eq ""
      end

      it "uses the textile-editor plugin"

      it_behaves_like "a form with a help button"

      describe "submitting the form with valid information" do
        before do
          select @issue_1.title, from: :evidence_issue_id
          fill_in :evidence_content, with: "This is some evidence"
        end

        let(:new_evidence) { @node.evidence.order("created_at ASC").last }

        it "creates a new piece of evidence authored by the current user" do
          expect{submit_form}.to change{@node.evidence.count}.by(1)
          expect(new_evidence.author).to eq @logged_in_as.email
          expect(new_evidence.issue).to eq @issue_1
        end

        include_examples "creates an Activity", :create, Evidence

        it "shows the new evidence" do
          submit_form
          expect(current_path).to eq project_node_evidence_path(current_project, @node, new_evidence)
          expect(page).to have_content "This is some evidence"
        end
      end

      describe "submitting the form with invalid information" do
        before do
          # No issue selected
          fill_in :evidence_content, with: "This is some evidence"
        end

        it "doesn't create a new piece of evidence" do
          expect{submit_form}.not_to change{Evidence.count}
        end

        include_examples "doesn't create an Activity"

        it "shows the form again" do
          submit_form
          expect(page).to have_field :evidence_issue_id
          expect(page).to have_field :evidence_content
        end
      end
    end

    context "when a NoteTemplate is specified" do
      let(:params)  { { template: "tmpevidence" } }

      it "pre-populates the textarea with the template contents" do
        textarea = find("textarea#evidence_content")
        expect(textarea.value.strip).to eq content
      end

      it "uses the textile-editor plugin"
    end

  end
end
