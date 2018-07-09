class NotificationsController < AuthenticatedController
  include ProjectScoped

  def index
    @notifications =
      if params[:count]
        current_user.notifications.newest.limit(params[:count])
      else
        current_user.notifications.newest
      end

    present_notifications

    respond_to do |format|
      format.json { render json: present_notifications }
    end
  end

  private

  def present_notifications
    @notifications.map do |notification|
      presenter = NotificationPresenter.new(notification, view_context)
      {
        avatar: presenter.avatar_with_link(30),
        created_at_ago: presenter.created_at_ago,
        icon: presenter.icon,
        render_title: presenter.render_title,
        unread: notification.unread?
      }
    end
  end
end
