class NotificationsController < AuthenticatedController
  include ProjectScoped

  skip_before_action :set_project, if: -> { params[:project_id].blank? }
  skip_before_action :set_nodes, if: -> { params[:project_id].blank? }

  def index
    notifications = current_user.notifications.newest.includes(
      :actor, notifiable: [:user, :commentable]
    )
    respond_to do |format|
      format.html do
        @notifications = notifications.page(params[:page])
      end
      format.js do
        @project_id = params[:project_id]
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

      f.html { redirect_to notifications_path }
    end
  end

  protected

  # ProjectScoped always call ProjectScoped#info_for_paper_trail with the current_project.
  # We have to overwrite it here so that it doesn't return an error.
  def info_for_paper_trail
    return if params[:project_id].blank?

    super
  end
end
