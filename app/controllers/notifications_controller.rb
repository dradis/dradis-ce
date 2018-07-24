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

  def update
    @notifications =
      if params[:id] == 'all'
        current_user.notifications
      elsif params[:id]
        current_user.notifications.where(id: params[:id])
      end

    @notifications.each(&:read!)

    @has_unread = current_user.notifications.unread.any?

    respond_to do |f|
      f.js do
        if changed_notifications_count > 0
          @ids = @notifications.map(&:id)
        else
          head :ok
        end
      end

      # TODO s/@project/current_project once project-id-scopes is merged
      f.html { redirect_to project_notifications_path(@project) }
    end
  end


  private

  def changed_notifications_count
    @changed_notifications_count ||=
      @notifications.count(&:read_at_previously_changed?)
  end
end
