class NotificationGroup
  def initialize(notifications)
    @notifications = build_notifications_hash(notifications)
  end

  def count
    @notifications.values.inject(0) do |sum, project_notifications|
      project_total = project_notifications.inject(0) do |p_sum, p_notifications|
        p_sum + p_notifications[1].count
      end
      sum + project_total
    end
  end

  def each(&block)
    @notifications.each(&block)
  end

  def raw_hash
    @notifications
  end


  private

  # The resulting notifications hash has the format:
  # {
  #   project1 => [
  #     [item1, [notifications]],
  #     [item2, ...]
  #   ],
  #   project2 => ...
  # }
  def build_notifications_hash(notifications)
    notifications_hash = notifications.
      # FIXME: This only applies to notifications coming from a comment
      group_by { |n| n.notifiable.commentable }

    project = Project.new
    notifications_hash.group_by do |item, _|
      if defined?(Dradis::Pro)
        item.project
      else
        # We use a single instance of Project since the project instance in each
        # item.project call in CE is different.
        project
      end
    end
  end
end
