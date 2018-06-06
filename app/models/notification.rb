class Notification < ApplicationRecord
  belongs_to :actor, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  scope :unread,  -> { where(read_at: nil) }
  scope :read,    -> { where.not(read_at: nil) }

  def read?
    self.read_at
  end
end
