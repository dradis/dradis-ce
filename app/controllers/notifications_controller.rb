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
    @notification =
      current_user.notifications.where(id: params[:id]).mark_as_read
    head :no_content
  end

  def read_all
    current_user.notifications.where(read_at: nil).each(&:mark_as_read)
    head :no_content
  end
end
