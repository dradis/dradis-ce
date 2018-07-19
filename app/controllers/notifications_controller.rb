class NotificationsController < AuthenticatedController
  include ProjectScoped

  def index
    # TODO this doesn't fix all the N+1 query problems, needs a closer look:
    notifs = current_user.notifications.newest.includes(:actor, notifiable: [:user, :commentable])
    respond_to do |format|
      format.html do
        @notifications = notifs.page(params[:page])
        @unread_count  = @notifications.unread.count
      end
      format.js do
        @notifications = notifs.limit(20)
        # TODO how can we avoid this repetition of '@unread_count = ...'?
        @unread_count  = @notifications.unread.count
      end
    end
  end
end
