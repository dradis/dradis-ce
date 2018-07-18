class NotificationsController < AuthenticatedController
  include ProjectScoped

  def index
    respond_to do |format|
      format.html do
        @notifications = current_user.notifications.newest.page(params[:page])
        @unread_count  = @notifications.unread.count
      end
      format.js do
        @notifications = current_user.notifications.newest.limit(20)
        # TODO how can we avoid this repetition of '@unread_count = ...'?
        @unread_count  = @notifications.unread.count
      end
    end
  end
end
