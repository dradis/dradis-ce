require 'rails_helper'

describe "Describe attachments" do
  it "should require authenticated users" do
    node = create(:node)
    visit project_node_attachments_path(node.project, node)

    expect(current_path).to eq(login_path)
    expect(page).to have_content('Access denied.')
  end

  describe "as authenticated user" do
    before do
      login_to_project_as_user
      @node = create(:node, project: current_project)
    end

    after do
      FileUtils.rm_rf(Attachment.pwd.join(@node.id.to_s))
    end

    it "stores the file on disk" do
      visit project_node_path(current_project, @node)

      file_path = Rails.root.join('spec/fixtures/files/rails.png')
      attach_file('files[]', file_path)
      click_button 'Start'

      expect(page).to have_content('rails.png')
      expect(File.exist?(Attachment.pwd.join(@node.id.to_s, 'rails.png'))).to be true
    end

    it "auto-renames the upload if an attachment with the same name already exists" do
      node_attachments = Attachment.pwd.join(@node.id.to_s)
      FileUtils.rm_rf(node_attachments)
      FileUtils.mkdir_p(node_attachments)

      FileUtils.cp( Rails.root.join('spec/fixtures/files/rails.png'), node_attachments.join('rails.png') )
      expect(Dir["#{node_attachments}/*"].count).to eq(1)

      visit project_node_path(current_project, @node)

      file_path = Rails.root.join('spec/fixtures/files/rails.png')
      attach_file('files[]', file_path)
      click_button 'Start'

      expect(Dir["#{node_attachments}/*"].count).to eq(2)
    end
  end
end
#
