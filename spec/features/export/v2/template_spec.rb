# DEPRECATED - this class is v2 of the Template Exporter and shouldn't be updated.
# V4 released on Apr 2022
# V2 can be removed on Apr 2024
#
# We're duplicating this file for v4, and even though the code lives in two
# places now, this file isn't expected to evolve and is now frozen to V2
# behavior.

require 'rails_helper'

describe 'exporting comments', skip: true do
  before { login_to_project_as_user }

  context 'issue with a comment' do
    before do
      @issue = create(:issue,
        text: 'Sample issue',
        node: current_project.issue_library
      )
      @comment = create(:comment,
        content: 'Sample comment',
        commentable: @issue,
        user: @logged_in_as
      )
    end

    it 'creates the comment xml' do
      export_options = {
        plugin: Dradis::Plugins::Projects,
        project_id: current_project.id
      }
      exporter =
        Dradis::Plugins::Projects::Export::V2::Template.new(export_options)

      comment_xml = '<comment>'\
        '<content><![CDATA[Sample comment]]></content>'\
        "<author>#{@logged_in_as.email}</author>"\
        "<created_at>#{@comment.created_at.to_i}</created_at>"\
        '</comment>'
      expect(exporter.export).to include(comment_xml)
    end
  end
end
