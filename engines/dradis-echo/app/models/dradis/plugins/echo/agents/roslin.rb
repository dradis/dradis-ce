module Dradis::Plugins::Echo
  module Agents
    # Convenience wrapper so callers can use Agents::Roslin.enabled? instead
    # of scattering Agent.find_by lookups across controllers, views, and jobs.
    module Roslin
      extend self

      def enabled?
        instance&.enabled? || false
      end

      def instance
        Agent.find_by(name: 'Roslin')
      end

      delegate :id, :model_override, :provider, to: :instance, allow_nil: true
    end
  end
end
