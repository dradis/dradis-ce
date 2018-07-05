require 'rails_helper'

describe 'exporting comments' do
  before { login_to_project_as_user }

  context 'issue with a comment' do
    before do
      @issue = create(:issue, text: 'Sample issue')
      @comment = @issue.comments.create(
        content: 'Sample comment',
        user_id: @logged_in_as.id
      )
    end

    it 'creates the comment xml' do
      export_options = {plugin: Dradis::Plugins::Projects}
      @exporter =
        Dradis::Plugins::Projects::Export::V2::Template.new(export_options)

      comment_xml = "<comment>"\
        "<content><![CDATA[Sample comment]]></content>"\
        "<author>#{@logged_in_as.email}</author>"\
        "<created_at>#{@comment.created_at.to_i}</created_at>"\
        "</comment>"
      expect(@exporter.export).to include(comment_xml)
    end
  end
end
