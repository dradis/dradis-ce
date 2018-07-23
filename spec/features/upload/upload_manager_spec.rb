require 'rails_helper'

describe 'upload manager spec' do
  before { login_to_project_as_user }

  let(:importer_class) { Dradis::Plugins::Projects::Upload::Template::Importer }
  let(:importer) { instance_double(importer_class) }
  let(:uploads_node) { Node.plugin_uploads_node }

  context 'template with size <1mb' do
    before do
      allow(importer_class).to receive(:new).and_return(importer)
      allow(importer).to receive(:import)

      visit project_upload_manager_path(@project)
    end

    it 'imports the uploaded template', js: true do
      expect(importer_class).to receive(:new).with(
        hash_including(default_user_id: User.first.id)
      )
      expect(importer).to receive(:import)

      file_path =
        Rails.root.join(
          "spec", "fixtures", "files", "templates", "with_comments.xml"
        )
      select "Dradis::Plugins::Projects::Upload::Template"
      attach_file "file", file_path
    end
  end
end
