module Reviewable
  extend ActiveSupport::Concern

  included do
    enum :state, [ :draft, :ready_for_review, :published ]
  end
end
