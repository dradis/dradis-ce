json.filename attachment.filename
json.size @file_size
json.created_at @created_at
json.link main_app.project_node_attachment_path(current_project, @node, attachment.filename)
json.download download_node_attachment_url(@node, attachment.filename)
