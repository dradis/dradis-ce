require 'rails_helper'

describe Dradis::Plugins::Projects::Upload::V3::Template::Importer do
  before do
    login_to_project_as_user

    @importer = described_class.new(
      default_user_id: User.first.id,
      plugin: importer_class,
      project_id: current_project.id
    )
  end

  let(:importer_class) { Dradis::Plugins::Projects::Upload::Template }
  let(:with_node_boards) {
    Rails.root.join('spec', 'fixtures', 'files', 'templates', 'with_node_boards.xml')
  }
  let(:without_node_id) {
    Rails.root.join('spec', 'fixtures', 'files', 'templates', 'without_node_id.xml')
  }

  context 'uploading a template with boards' do
    before { @importer.import(file: with_node_boards) }

    it 'imports the boards under the correct nodes' do
      node = current_project.nodes.find_by_label('10.0.0.1')
      expect(node).to_not be_nil

      board = node.boards.find_by_name('Board')
      expect(board).to_not be_nil
    end

    it 'imports the project boards' do
      project_board =
        current_project.methodology_library.boards.find_by_name('Project Board')
      expect(project_board).to_not be_nil
    end
  end

  context 'uploading a template (old) with boards without <node_id>' do
    it 'imports the boards correctly' do
      @importer.import(file: without_node_id)

      board = Board.where(
        name: 'Board',
        node: current_project.methodology_library
      ).first
      expect(board).to_not be_nil
    end
  end
end
