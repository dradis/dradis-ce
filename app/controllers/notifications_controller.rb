class NotificationsController < AuthenticatedController
  include ProjectScoped

  def index
    notifications = current_user.notifications.newest.includes(
      :actor, :notifiable
    )
    respond_to do |format|
      format.html do
        @notifications = notifications.page(params[:page])
      end
      format.js do
        @notifications = notifications.limit(20)
        # NB the unread count is not the same as @notifications.count because
        # @notifications a) includes read notifs and b) is capped at 20
        @unread_count  = current_user.notifications.unread.count
      end
    end
  end

  def update
    @notifications =
      if params[:id] == 'all'
        current_user.notifications
      elsif params[:id]
        current_user.notifications.where(id: params[:id])
      end

    @updated_count = @notifications.unread.mark_all_as_read!

    @has_unread = current_user.notifications.unread.any?

    respond_to do |f|
      f.js do
        if @updated_count > 0
          @ids = @notifications.map(&:id)
        else
          head :ok
        end
      end

      f.html { redirect_to project_notifications_path(current_project) }
    end
  end
end
