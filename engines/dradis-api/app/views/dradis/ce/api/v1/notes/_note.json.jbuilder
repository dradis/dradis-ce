json.(note, :id, :category_id, :title, :fields, :text)
json.comments_count note.comments.count
json.comments_url node_note_comments_path(@node, note)
