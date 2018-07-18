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
    @notification = current_user.notifications.find(params[:id]).mark_as_read
    render json: {id: params[:id]}
  end

  def read_all
    current_user.notifications.each(&:mark_as_read)
    head :no_content
  end
end
