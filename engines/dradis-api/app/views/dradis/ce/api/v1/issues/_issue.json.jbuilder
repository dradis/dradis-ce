json.(issue, :id, :title, :fields, :text, :state, :created_at, :updated_at)
json.tags issue.tags, :color, :display_name
