require 'rails_helper'

describe 'Restoring project files' do
  before { login_to_project_as_user }

  context 'with v1 methodologies data' do
    before do
      visit project_upload_path(current_project)
    end

    it 'transforms methodologies into boards', js: true do
      select 'Dradis::Plugins::Projects::Upload::Template'
      attach_file \
        'file',
        Rails.root.join(
          'spec', 'fixtures', 'files', 'projects', 'with_v1_methodologies.xml'
        ),
        visible: false,
        disabled: false

      expect(page).to have_text('Processing V1 Methodologies...', wait: 120)
      expect(page).to have_text('Worker process completed', wait: 120)

      expect(current_project.boards.count).to eq 1
      expect(current_project.boards.first.name).to eq 'OWASPv4 Methodology'

      expect(current_project.boards.first.lists.map(&:name)).to eq ['Pending', 'Done']
    end
  end
end
