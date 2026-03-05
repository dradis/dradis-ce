json.array! @threads do |thread|
  json.id thread.id
  json.status thread.status
  json.outdated thread.outdated?
  json.created_at thread.created_at.iso8601
  json.resolved_at thread.resolved_at&.iso8601

  json.user do
    json.id thread.user.id
    json.name thread.user.name
  end

  if thread.resolved_by
    json.resolved_by do
      json.id thread.resolved_by.id
      json.name thread.resolved_by.name
    end
  end

  json.anchor thread.anchor

  json.comments thread.comments do |comment|
    json.id comment.id
    json.content comment_formatter(comment.content)
    json.raw_content comment.content
    json.created_at comment.created_at.iso8601

    json.user do
      json.id comment.user_id
      json.name comment.user&.name || 'Unknown'
    end
  end
end
