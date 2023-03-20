require 'rails_helper'

describe 'Pro export template' do
  before { login_to_project_as_user }

  let(:export_options) {
    { plugin: Dradis::Plugins::Projects, project_id: current_project.id }
  }

  context 'exporting boards' do
    before do
      @boards_library = current_project.methodology_library
      @project_board = create(
        :board,
        project: current_project,
        node: @boards_library
      )
      @node = create(:node, project: current_project)
      @node_board = create(:board, project: current_project, node: @node)

      @exporter =
        Dradis::Plugins::Projects::Export::V3::Template.new(export_options)

      @result = @exporter.export
    end

    it 'creates the project board xml' do
      project_board_xml = "<board version=\"3\"><id>#{@project_board.id}</id>"\
      "<name>#{@project_board.name}</name><node_id/></board>"

      expect(@result).to include(project_board_xml)
    end

    it 'creates the node board xml' do
      node_board_xml = "<board version=\"3\"><id>#{@node_board.id}</id>"\
      "<name>#{@node_board.name}</name>"\
      "<node_id>#{@node.id}</node_id></board>"

      expect(@result).to include(node_board_xml)
    end

    context 'card with a comment' do
      let(:card) do
        board = create(:board, node: current_project.methodology_library, project: current_project)
        list = create(:list, board: board)
        create(:card, list: list)
      end

      let(:comment) do
        create(:comment,
          content: 'Sample card comment',
          commentable: card,
          user: @logged_in_as
        )
      end

      it 'creates the comment xml' do
        export_options = {
          plugin: Dradis::Plugins::Projects,
          project_id: current_project.id
        }
        exporter =
          Dradis::Plugins::Projects::Export::V3::Template.new(export_options)

        comment_xml = "<comment>"\
          "<content><![CDATA[Sample card comment]]></content>"\
          "<author>#{@logged_in_as.email}</author>"\
          "<created_at>#{comment.created_at.to_i}</created_at>"\
          "</comment>"
        expect(exporter.export).to include(comment_xml)
      end
    end
  end
end
