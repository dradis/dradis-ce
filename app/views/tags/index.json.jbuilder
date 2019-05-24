json.array! @tags do |tag|
  json.name tag.display_name
  json.color tag.color
  json.value tag.name
end