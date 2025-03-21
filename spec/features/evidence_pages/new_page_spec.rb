require 'rails_helper'

describe 'Evidence new page' do
  subject { page }

  before do
    login_to_project_as_user
    @issue = create(:issue, node: current_project.issue_library)
  end

  describe 'add evidence', :js do
    before do
      @node = current_project.nodes.create!(label: '192.168.0.1')

      template_path = Rails.root.join('spec/fixtures/files/note_templates/')
      allow(NoteTemplate).to receive(:pwd).and_return(template_path)

      visit new_project_issue_evidence_path(current_project, @issue)
    end

    it 'shows existing nodes' do
      within('[data-behavior~=combobox-container]:has(#evidence_node_ids)') do
        expect(page).to have_text @node.label
      end
    end

    it 'creates an evidence with the selected template for selected node' do
      visit new_project_issue_evidence_path(current_project, @issue, template: 'simple_note')
      find('.unselect-multi-option').click # deselect initial selection
      within('[data-behavior~=combobox-container]:has(#evidence_node_ids)') do
        find('.combobox').click
        find('.combobox-option', text: @node.label).click
      end
      
      expect { click_button('Create Evidence') }.to change { Evidence.count }.by(1)

      evidence = Evidence.last
      expect(evidence.content).to eq(NoteTemplate.find('simple_note').content.gsub("\n", "\r\n"))
      expect(evidence.node.label).to eq '192.168.0.1'
    end

    it 'creates an evidence for new nodes and existing nodes too' do
      fill_in 'evidence_node_list', with: "192.168.0.1\r\n192.168.0.2\r\n192.168.0.3"
      find('.unselect-multi-option').click # deselect initial selection
      expect do
        click_button('Create Evidence')
        expect(page).to have_text 'Evidence added for selected nodes.'
      end.to change { Evidence.count }.by(3).and change { Node.count }.by(2)

      # Check that new nodes don't have a parent:
      current_project.nodes.order('created_at ASC').last(2).each do |node|
        expect(node.parent).to be_nil
      end
    end

    it 'assigns new nodes to the right parent' do
      fill_in 'evidence_node_list', with: "#{@node.label}\r\naaaa"
      find('.unselect-multi-option').click # deselect initial selection
      within('[data-behavior~=combobox-container]:has(#evidence_node_list_parent_id)') do
        find('.combobox').click
        find('.combobox-option', text: @node.label).click
      end

      expect do
        click_button('Create Evidence')
      end.to change { Evidence.count }.by(2).and change { Node.count }.by(1)

      # Check if existing nodes' parents have their parent changed
      expect(@node.reload.parent).to be_nil

      new_node = current_project.nodes.find_by!(label: 'aaaa')
      expect(new_node.parent).to eq @node
    end

    it 'tracks "create" activities for new evidence and nodes' do
      fill_in 'evidence_node_list', with: "#{@node.label}\r\naaaa"
      find('.unselect-multi-option').click # deselect initial selection
      expect do
        click_button('Create Evidence')
        expect(page).to have_text 'Evidence added for selected nodes.'
      end.to change { enqueued_activity_tracking_jobs.size }.by(3)

      jobs = enqueued_activity_tracking_jobs.last(3)
      expect(enqueued_job_args(jobs, 'action')).to eq Array.new(3, 'create')
      expect(enqueued_job_args(jobs, 'trackable_type')).to \
        match_array(%w[Evidence Evidence Node])
    end

    it 'assigns the current user as the evidence author' do
      find('.unselect-multi-option').click # deselect initial selection
      within('[data-behavior~=combobox-container]:has(#evidence_node_ids)') do
        find('.combobox').click
        find('.combobox-option', text: @node.label).click
      end
      expect { click_button('Create Evidence') }.to change { Evidence.count }.by(1)
      expect(@node.reload.evidence.last.author).to eq(@logged_in_as.email)
    end

    context 'invalid form', js: true do
      it 'displays an error when no nodes are selected' do
        within('[data-behavior~=combobox-container]:has(#evidence_node_ids)') do
        find('.unselect-multi-option').click
      end
        click_button 'Create Evidence'
        expect(page).to have_text('A node must be selected.')
      end
    end

    # we need to filter by job class because a NotificationsReaderJob
    # will also be enqueued
    def enqueued_activity_tracking_jobs
      ActiveJob::Base.queue_adapter.enqueued_jobs.select do |hash|
        hash[:job] == ActivityTrackingJob
      end
    end

    def enqueued_job_args(job_hashes, key)
      job_hashes.map { |h| h[:args].map { |h2| h2[key] } }.flatten
    end
  end
end
