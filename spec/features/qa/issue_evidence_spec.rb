require 'rails_helper'

describe 'QA issue evidence' do
  before { login_to_project_as_user }

  let(:issue) { create(:issue, state: :ready_for_review, node: current_project.issue_library) }
  let(:node) { create(:node, project: current_project) }
  let!(:evidence) { create(:evidence, issue: issue, node: node, state: :ready_for_review) }

  describe 'evidence tab', js: true do
    before { visit project_qa_issue_path(current_project, issue) }

    it 'lists the evidence for the issue' do
      click_link 'Evidence'

      expect(page).to have_content(node.label)
    end

    context 'with evidence not ready for review' do
      let!(:draft_node) { create(:node, project: current_project, label: 'Node with draft evidence') }
      let!(:draft_evidence) { create(:evidence, issue: issue, node: draft_node, state: :draft) }

      before { visit project_qa_issue_path(current_project, issue) }

      it 'only lists evidence that is ready for review' do
        click_link 'Evidence'

        within '.dataTables_wrapper' do
          expect(page).to have_content(node.label)
          expect(page).to have_no_content(draft_node.label)
        end
      end
    end
  end

  describe 'evidence tab link', js: true do
    before do
      visit project_qa_issue_path(current_project, issue)
      click_link 'Evidence'
    end

    it 'links to the QA evidence show page instead of the node-scoped one' do
      within '.dataTables_wrapper' do
        click_link node.label
      end

      expect(page).to have_current_path(project_qa_issue_evidence_path(current_project, issue, evidence))
    end
  end

  describe 'show page', js: true do
    before { visit project_qa_issue_evidence_path(current_project, issue, evidence) }

    it 'links the issue breadcrumb back to the evidence tab' do
      within 'nav .breadcrumb' do
        click_link issue.title
      end

      expect(page).to have_current_path(project_qa_issue_path(current_project, issue, tab: 'evidence-tab'))
    end

    context 'with more than one piece of evidence ready for review' do
      let(:other_node) { create(:node, project: current_project) }
      let!(:other_evidence) { create(:evidence, issue: issue, node: other_node, state: :ready_for_review) }

      before { visit project_qa_issue_evidence_path(current_project, issue, evidence) }

      it 'lists all the evidence ready for review in the sidebar' do
        within '.secondary-sidebar [data-behavior~=sidebar-content]' do
          expect(page).to have_link(node.label, href: project_qa_issue_evidence_path(current_project, issue, evidence))
          expect(page).to have_link(other_node.label, href: project_qa_issue_evidence_path(current_project, issue, other_evidence))
        end
      end

      it 'excludes evidence ready for review that belongs to a different issue' do
        other_issue = create(:issue, state: :ready_for_review, node: current_project.issue_library)
        other_issue_node = create(:node, project: current_project, label: 'Node for a different issue')
        create(:evidence, issue: other_issue, node: other_issue_node, state: :ready_for_review)

        visit project_qa_issue_evidence_path(current_project, issue, evidence)

        within '.secondary-sidebar [data-behavior~=sidebar-content]' do
          expect(page).to have_no_content(other_issue_node.label)
        end
      end

      it 'updates the state and shows the next evidence ready for review' do
        click_button 'Published'

        expect(evidence.reload.state).to eq 'published'
        expect(page).to have_current_path(project_qa_issue_evidence_path(current_project, issue, other_evidence))
      end
    end

    it 'redirects to the evidence tab when there is no more evidence ready for review' do
      click_button 'Published'

      expect(evidence.reload.state).to eq 'published'
      expect(page).to have_current_path(project_qa_issue_path(current_project, issue, tab: 'evidence-tab'))
    end
  end

  describe 'bulk state update', js: true do
    before do
      visit project_qa_issue_path(current_project, issue)
      click_link 'Evidence'
    end

    it 'updates the selected evidence state' do
      page.find('td.select-checkbox', match: :first).click
      click_button 'State'
      click_link 'Published'

      Timeout.timeout(Capybara.default_max_wait_time) do
        sleep 0.1 until evidence.reload.state == 'published'
      end

      expect(evidence.state).to eq 'published'
    end

    it 'removes the row once it is no longer ready for review' do
      page.find('td.select-checkbox', match: :first).click
      click_button 'State'
      click_link 'Published'

      expect(page).to have_no_selector("tr#evidence-#{evidence.id}")
    end

    context 'when the user is not a reviewer' do
      before do
        other_user = create(:user)
        allow_any_instance_of(Project).to receive(:reviewers).and_return(User.where(id: other_user.id))
        visit project_qa_issue_path(current_project, issue)
        click_link 'Evidence'
      end

      it 'disables the published state option' do
        page.find('td.select-checkbox', match: :first).click
        click_button 'State'

        expect(page).to have_css('.dt-button.dropdown-item.disabled', text: 'Published')
      end
    end
  end
end
