require 'rails_helper'

describe Dradis::Plugins::Projects::Upload::V2::Template::Importer do
  before do
    login_to_project_as_user

    @importer = importer_class::Importer.new(
      default_user_id: User.first.id,
      plugin: importer_class,
      project_id: current_project.id
    )
  end

  let(:importer_class) { Dradis::Plugins::Projects::Upload::Template }
  let(:with_comments) {
    Rails.root.join('spec', 'fixtures', 'files', 'templates', 'with_comments.xml')
  }

  context 'uploading a template with comments' do
    it 'imports the comments' do
      @importer.import(file: with_comments)

      expect(Comment.count).to eq(1)
      expect(Comment.last.content).to include('Hello World')
    end
  end
end
