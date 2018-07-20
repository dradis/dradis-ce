class NotificationsController < AuthenticatedController
  include ProjectScoped

  def index
    @notifications = current_user.notifications.newest.limit(20)
    @unread_count = @notifications.unread.count

    respond_to do |format|
      format.js
    end
  end

  def update
    notifications =
      if params[:id] == 'all'
        current_user.notifications
      elsif params[:id]
        current_user.notifications.where(id: params[:id])
      end

    notifications.each(&:read!)

    @has_unread = current_user.notifications.unread.any?

    respond_to do |f|
      f.js {
        render json: {
          ids: notifications.map(&:id),
          has_unread: @has_unread
        }
      }
      # TODO s/@project/current_project once project-id-scopes is merged
      f.html { redirect_to project_notifications_path(@project) }
    end
  end
end
