require 'rails_helper'

describe 'Edit locking multi-actor flow' do
  describe 'for an issue' do
    let(:project) { create(:project) }
    let(:issue) { create(:issue, node: project.issue_library) }
    let(:record) { issue }
    let(:edit_path) { edit_project_issue_path(project, issue) }

    let(:submit_form) do
      find('.btn-states button[type="submit"]').click
      expect(page).to have_content('Issue updated.')
    end

    it_behaves_like 'a lockable resource'
  end

  describe 'for a note' do
    let(:project) { create(:project) }
    let(:node) { create(:node, project: project) }
    let(:note) { create(:note, node: node) }
    let(:record) { note }
    let(:edit_path) { edit_project_node_note_path(project, node, note) }

    let(:submit_form) { click_button 'Update Note' }

    it_behaves_like 'a lockable resource'
  end
end
