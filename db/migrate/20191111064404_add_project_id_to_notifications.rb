class AddProjectIdToNotifications < ActiveRecord::Migration[5.1]
  def up
    add_reference :notifications, :project, index: true

    project = Project.new
    Notification.includes(notifiable: :commentable).each do |n|
      if defined?(Dradis::Pro)
        item = n.notifiable.commentable
        n.update_attribute :project_id, item.project.id
      else
        n.update_attribute :project_id, project.id
      end
    end
  end

  def down
    remove_reference :notifications, :project, index: true
  end
end
