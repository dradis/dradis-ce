json.(board, :id, :name, :node_id, :created_at, :updated_at)

json.lists board.lists do |list|
  json.partial! list
end
