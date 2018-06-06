module Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, as: :notifiable
  end
end
