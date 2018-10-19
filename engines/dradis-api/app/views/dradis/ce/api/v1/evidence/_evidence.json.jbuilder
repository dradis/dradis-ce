json.(evidence, :id, :content, :fields)
json.issue do |json|
  json.id evidence.issue_id
  json.title evidence.issue.title
  json.url dradis_api.issue_url(evidence.issue_id)
end
json.comments_count evidence.comments.count
json.comments_url evidence_comments_path(evidence)
