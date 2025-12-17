json.(list, :id, :name, :created_at, :updated_at)

json.cards list.cards do |card|
  json.partial! card
end
