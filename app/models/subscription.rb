class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :subscribable, polymorphic: true
end
