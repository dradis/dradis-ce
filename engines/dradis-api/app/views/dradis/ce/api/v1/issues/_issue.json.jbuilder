json.(issue, :id, :title, :fields, :text, :created_at, :updated_at)
json.comments_count issue.comments_count
json.comments_url issue_comments_path(issue)
