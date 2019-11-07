class NotificationGroup
  attr_reader :count, :notifications_hash

  def initialize(notifications)
    @notifications_hash = build_notifications_hash(notifications)
    @count = notifications.count
  end

  def each(&block)
    @notifications_hash.each(&block)
  end

  def to_h
    @notifications_hash
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
    hash = notifications.
      # FIXME: This only applies to notifications coming from a comment
      group_by { |n| n.notifiable.commentable }

    project = Project.new
    hash.group_by do |item, _|
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
