class NotificationsController < AuthenticatedController
  include ProjectScoped

  def index
    @notifications = current_user.notifications.newest.limit(20)
    @unread_count = @notifications.unread.count

    respond_to do |format|
      format.js
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
