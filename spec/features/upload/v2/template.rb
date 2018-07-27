require 'rails_helper'


describe Dradis::Plugins::Projects::Upload::V2::Template::Importer do
  before do
    login_to_project_as_user
  end


  let(:importer_class) { Dradis::Plugins::Projects::Upload::Template }
  let(:file_path) {
    Rails.root.join( "spec", "fixtures", "files", "templates", "with_comments.xml")
  }

  context 'uploading a template with comments' do
    it 'imports the comments' do
      importer = importer_class::Importer.new(
        default_user_id: User.first.id,
        plugin: importer_class
      )

      output = importer.import(file: file_path)

      expect(Comment.count).to eq(1)
      expect(Comment.last.content).to include('Hello World')
    end
  end
end
