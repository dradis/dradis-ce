module Dradis::Plugins::Echo
  class Agent < ApplicationRecord
    belongs_to :provider

    enum :agent_type, %i[system user], default: :user

    validates :name, presence: true, uniqueness: true

    before_destroy :prevent_system_deletion

    private
      def prevent_system_deletion
        throw(:abort) if system?
      end
  end
end
