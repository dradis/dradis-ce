class EditorChannel < ApplicationCable::Channel
  def save(params)
    puts "auto save is happening"
    @issue = Issue.find(params['issue_id'])
    @issue.update_attributes(text: params['issue'])
  end
end
