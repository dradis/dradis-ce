module Dradis::Plugins::Echo
  module Agents
    # Convenience wrapper so callers can use Agents::Roslin.enabled? instead
    # of scattering Agent.find_by lookups across controllers, views, and jobs.
    module Roslin
      extend self

      def instance
        Agent.find_by!(name: 'Roslin')
      end

      def enabled?
        Agent.find_by(name: 'Roslin')&.enabled? || false
      end

      delegate :id, :model_override, :provider, to: :instance
    end
  end
end
