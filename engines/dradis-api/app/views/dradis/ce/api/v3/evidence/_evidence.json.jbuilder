json.(evidence, :id, :author, :content, :fields, :state)
json.issue do |json|
  json.id evidence.issue_id
  json.title evidence.issue.title
  json.url dradis_api.issue_url(evidence.issue_id)
end
