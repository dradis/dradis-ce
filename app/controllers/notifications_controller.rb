class NotificationsController < AuthenticatedController
  include ProjectScoped

  def index
    # TODO this doesn't fix all the N+1 query problems, needs a closer look:
    notifs = current_user.notifications.newest.includes(:actor, notifiable: [:user, :commentable])
    respond_to do |format|
      format.html do
        @notifications = notifs.page(params[:page])
      end
      format.js do
        @notifications = notifs.limit(20)
        # NB the unread count is not the same as @notifications.count because
        # @notifications a) includes read notifs and b) is capped at 20
        @unread_count  = current_user.notifications.unread.count
      end
    end
  end
end
