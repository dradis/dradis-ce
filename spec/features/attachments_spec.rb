require 'rails_helper'

describe 'Describe attachments' do
  it 'should require authenticated users' do
    node = create(:node)
    visit project_node_attachments_path(node.project, node)

    expect(current_path).to eq(login_path)
    expect(page).to have_content('Access denied.')
  end

  describe 'as authenticated user', :js do
    before do
      login_to_project_as_user
      @node = create(:node, project: current_project)
    end

    after do
      FileUtils.rm_rf(Attachment.pwd.join(@node.id.to_s))
    end

    it 'stores the file on disk' do
      visit project_node_path(current_project, @node)

      file_path = Rails.root.join('spec/fixtures/files/rails.png')
      attach_file('files[]', file_path, visible: false)
      wait_for_ajax
      expect(page).to have_content('rails.png')
      expect(File.exist?(Attachment.pwd.join(@node.id.to_s, 'rails.png'))).to be true
    end

    it 'auto-renames the upload if an attachment with the same name already exists' do
      node_attachments = Attachment.pwd.join(@node.id.to_s)
      FileUtils.rm_rf(node_attachments)
      FileUtils.mkdir_p(node_attachments)

      FileUtils.cp(Rails.root.join('spec/fixtures/files/rails.png'), node_attachments.join('rails.png'))
      expect(Dir["#{node_attachments}/*"].count).to eq(1)

      visit project_node_path(current_project, @node)

      file_path = Rails.root.join('spec/fixtures/files/rails.png')
      attach_file('files[]', file_path, visible: false)
      wait_for_ajax
      expect(Dir["#{node_attachments}/*"].count).to eq(2)
    end

    it 'builds a URL encoded link for attachments' do
      FileUtils.mkdir_p(Attachment.pwd.join(@node.id.to_s))

      filenames = ['attachment with space.png', 'attachmentwith&.png', 'attachmentwith+.png']

      filenames.each do |filename|
        attachment = Attachment.pwd.join(@node.id.to_s, filename)
        FileUtils.cp(Rails.root.join('spec/fixtures/files/rails.png'), attachment)
      end

      visit project_node_path(current_project, @node)

      filenames.each do |filename|
        url_encoded_filename = ERB::Util.url_encode(filename)
        expect(page).to have_css("button[data-clipboard-text='!/projects/#{current_project.id}/nodes/#{@node.id}/attachments/#{url_encoded_filename}!']")
      end
    end

    describe 'viewing the attachment' do
      before do
        visit project_node_path(current_project, @node)

        file_path = Rails.root.join('spec/fixtures/files/rails.png')
        attach_file('files[]', file_path)
        click_button 'Start'

        expect(page).to have_content('rails.png')
      end

      it 'does not render the attachment in the wrong project', skip: !defined?(Dradis::Pro) do
        new_project = create(:project)
        new_project.permissions << Permission.new(component: Dradis::Pro.permission_component_name, user: @logged_in_as, name: 'read-update')
        new_project.save!

        visit project_node_attachment_path(new_project, @node, 'rails.png')
        expect(page).to have_text('Node not found')
      end
    end
  end
end
