json.(issue, :id, :author, :title, :fields, :state, :text, :created_at, :updated_at)
json.tags issue.tags, :color, :display_name
