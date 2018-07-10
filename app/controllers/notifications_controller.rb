class NotificationsController < AuthenticatedController
  include ProjectScoped

  def index
    @notifications =
      if params[:count]
        current_user.notifications.newest.limit(params[:count].to_i)
      else
        current_user.notifications.newest
      end

    @unread_count = current_user.notifications.unread.count
  end
end
