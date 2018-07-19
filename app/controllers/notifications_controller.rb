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

  def read
    current_user.notifications.find(params[:id]).mark_as_read
    @has_unread = current_user.notifications.unread.any?
    respond_to do |f|
      f.js { render json: {id: params[:id], has_unread: @has_unread} }
      # TODO s/@project/current_project once project-id-scopes is merged
      f.html { redirect_to project_notifications_path(@project) }
    end
  end

  def read_all
    current_user.notifications.each(&:mark_as_read)
    respond_to do |f|
      f.js { head :no_content }
      # TODO s/@project/current_project once project-id-scopes is merged
      f.html { redirect_to project_notifications_path(@project) }
    end
  end
end
