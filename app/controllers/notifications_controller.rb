class NotificationsController < AuthenticatedController
  include ProjectScoped

  def index
    @notifications = current_user.notifications.newest
    @unread_count = @notifications.unread.count

    respond_to do |format|
      format.js
    end
  end

  def read
    current_user.notifications.find(params[:id]).mark_as_read
    @has_unread = current_user.notifications.unread.any?
    render json: {id: params[:id], has_unread: @has_unread}
  end

  def read_all
    current_user.notifications.each(&:mark_as_read)
    head :no_content
  end
end
