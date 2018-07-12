class NotificationsController < AuthenticatedController
  include ProjectScoped

  def index
    @notifications =
      if params[:count]
        current_user.notifications.newest.limit(params[:count].to_i)
      else
        current_user.notifications.newest
      end

    @unread_count = @notifications.unread.count

    respond_to do |format|
      format.js
    end
  end
end
