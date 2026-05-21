module Dradis::Plugins::Echo
  module Agents
    module Roslin
      def self.instance
        Agent.find_by!(name: 'Roslin')
      end

      delegate :enabled?, :id, :model_override, :provider, to: :instance
    end
  end
end
