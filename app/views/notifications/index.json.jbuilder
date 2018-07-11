json.count @unread_count
json.notifications do
  json.array! @notifications do |notification|
    present notification do |presenter|
      json.avatar presenter.avatar_with_link(30)
      json.created_at_ago presenter.created_at_ago
      json.icon presenter.icon
      json.render_title presenter.render_title
      json.unread  notification.unread?
    end
  end
end
