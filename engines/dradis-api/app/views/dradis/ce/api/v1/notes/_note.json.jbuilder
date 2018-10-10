json.(note, :id, :category_id, :title, :fields, :text)
json.comments_count note.comments_count
json.comments_url note_comments_path(note)
