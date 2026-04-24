require 'rails_helper'

describe 'Upload Manager' do
  before { login_to_project_as_user }

  describe 'restoring project files' do
    let(:fixture) do
      Rails.root.join('spec', 'fixtures', 'files', 'projects', 'with_v1_methodologies.xml')
    end

    before { visit project_upload_manager_path(current_project) }

    it 'transforms methodologies into boards', js: true do
      attach_file('upload_files', fixture, visible: false, make_visible: true)

      expect(page).to have_css('[data-controller~="upload-file"]', wait: 10)

      select 'Dradis::Plugins::Projects::Upload::Template', from: 'uploader'
      click_button 'Upload'

      expect(page).to have_button('View console', wait: 30)

      expect(current_project.boards.count).to eq 1
      expect(current_project.boards.first.name).to eq 'OWASPv4 Methodology'
      expect(current_project.boards.first.lists.map(&:name)).to eq ['Pending', 'Done']
    end
  end

  describe 'multi-file upload' do
    let(:fixture) do
      Rails.root.join('spec', 'fixtures', 'files', 'projects', 'welcome_project.xml')
    end

    before { visit project_upload_manager_path(current_project) }

    it 'shows a drop zone and an empty staging area on page load', js: true do
      expect(page).to have_css('.upload-drop-zone')
      expect(page).not_to have_css('[data-controller~="upload-file"]')
      expect(page).to have_button('Upload', disabled: true)
    end

    it 'adds one row per attached file', js: true do
      attach_file('upload_files', [fixture, fixture], visible: false, make_visible: true)

      expect(page).to have_css('[data-controller~="upload-file"]', count: 2, wait: 10)
    end

    it 'keeps the Upload button disabled until every row has a tool selected', js: true do
      attach_file('upload_files', [fixture, fixture], visible: false, make_visible: true)

      expect(page).to have_css('[data-controller~="upload-file"]', count: 2, wait: 10)
      expect(page).to have_button('Upload', disabled: true)

      all('[data-upload-file-target="toolSelect"]').each do |sel|
        sel.find('option', text: 'Dradis::Plugins::Projects::Upload::Template').select_option
      end

      expect(page).to have_button('Upload', disabled: false)
    end

    it 'removes a row when the Remove button is clicked', js: true do
      attach_file('upload_files', fixture, visible: false, make_visible: true)

      expect(page).to have_css('[data-controller~="upload-file"]', wait: 10)
      click_button 'Remove'
      expect(page).not_to have_css('[data-controller~="upload-file"]')
    end
  end
end
