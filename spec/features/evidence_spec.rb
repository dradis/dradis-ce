require 'spec_helper'

describe "evidence" do
  subject { page }

  let(:issue_lib) { Node.issue_library }

  before do
    login_to_project_as_user
    @node = create(:node)
    # Create IssueLibrary node in this project
    Node.create(label: 'All issues', type_id: Node::Types::ISSUELIB)
  end

  describe "show page" do
    before(:each) do
      e_text    = "#[Foobar]#\nBarfoo\n\n#[Fizzbuzz]#\nBuzzfizz"
      i_text    = "#[Issue Title]#\nIssue info"
      @issue    = create(:issue,    node: @node, text: i_text)
      @evidence = create(:evidence, node: @node, issue: @issue, content: e_text)
      create_activities
      visit node_evidence_path(@node, @evidence)
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
      let(:submit_form) { click_link "delete" }

      it "deletes the Evidence" do
        id = @evidence.id
        submit_form
        expect(Evidence.exists?(id)).to be false
      end

      let(:model) { @evidence }
      include_examples "creates an Activity", :destroy
    end
  end


  describe "edit page" do
    let(:submit_form) { click_button "Update Evidence" }

    before do
      issue = create(:issue, node: issue_lib)
      @evidence = create(:evidence, issue: issue, updated_at: 2.seconds.ago)
      visit edit_node_evidence_path(@node, @evidence)
    end

    CONFLICT_WARNING = \
      "Warning: another user updated this evidence while you were editing "\
      "it. Your changes have been saved, but you may have overwritten "\
      "their changes. You may want to review the revision history "\
      "to make sure nothing important has been lost"

    it "uses the full-screen editor plugin" # TODO

    it_behaves_like "a form with a help button"

    describe "submitting the form with valid information" do
      before { fill_in :evidence_content, with: "new content" }

      it "updates the evidence" do
        submit_form
        expect(@evidence.reload.content).to eq "new content"
        expect(current_path).to eq node_evidence_path(@node, @evidence)
      end

      it "doesn't say anything about edit conflicts" do
        submit_form
        expect(page).to have_no_content CONFLICT_WARNING
        expect(page).to have_no_link(//, href: node_evidence_revisions_path(@node, @evidence))
      end

      let(:model) { @evidence }
      include_examples "creates an Activity", :update

      context "when another user has updated the evidence in the meantime" do
        before do
          @evidence.update_attributes!(content: "Someone else's changes")
        end

        it "saves my changes" do
          submit_form
          expect(@evidence.reload.content).to eq "new content"
        end

        it "shows the updated evidence with a warning and a link to the revision history" do
          submit_form
          expect(current_path).to eq node_evidence_path(@node, @evidence)
          expect(page).to have_content CONFLICT_WARNING
          expect(page).to have_link(
            "revision history",
            href: node_evidence_revisions_path(@node, @evidence)
          )
        end

        DATE_FORMAT = "%b %e %Y, %-l:%M%P"

        it "links to the previous versions" do
          submit_form
          all_versions = @evidence.versions.order("created_at ASC")
          my_version   = all_versions[-1]
          conflict     = all_versions[-2]
          old_versions = all_versions - [my_version, conflict]

          expect(page).to have_link(
            "Your update at #{my_version.created_at.strftime(DATE_FORMAT)}",
            href: node_evidence_revision_path(@node, @evidence, my_version),
          )

          expect(page).to have_link(
            "Update while you were editing at #{conflict.created_at.strftime(DATE_FORMAT)}",
            href: node_evidence_revision_path(@node, @evidence, conflict),
          )

          old_versions.each do |version|
            expect(page).to have_no_link(//, node_evidence_revision_path(@node, @evidence, version))
          end
        end

        context "when there has been more than one edit" do
          before do
            @evidence.update_attributes!(content: "More conflicts")
            submit_form
          end

          it "links to them all" do
            submit_form
            all_versions = @evidence.versions.order("created_at ASC")
            my_version   = all_versions[-1]
            conflicts    = all_versions[-3..-2]
            old_versions = all_versions - [my_version] - conflicts

            expect(page).to have_link(
              "Your update at #{my_version.created_at.strftime(DATE_FORMAT)}",
              href: node_evidence_revision_path(@node, @evidence, my_version),
            )

            conflicts.each do |conflict|
              expect(page).to have_link(
                "Update while you were editing at #{conflict.created_at.strftime(DATE_FORMAT)}",
                href: node_evidence_revision_path(@node, @evidence, conflict),
              )
            end

            old_versions.each do |version|
              expect(page).to have_no_link(//, node_evidence_revision_path(@node, @evidence, version))
            end
          end
        end
      end
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
      visit new_node_evidence_path(@node, params)
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
          expect(current_path).to eq node_evidence_path(@node, new_evidence)
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
