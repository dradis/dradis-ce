module Dradis::Plugins::Echo
  module Agents
    # Convenience wrapper so callers can use Agents::Roslin.enabled? instead
    # of scattering Agent.find_by lookups across controllers, views, and jobs.
    module Roslin
      extend self

      def instance
        Agent.find_by!(name: 'Roslin')
      end

      delegate :enabled?, :id, :model_override, :provider, to: :instance

      def language_tool_configured?
        instance.env['LANGUAGETOOL_ADDRESS'].present?
      end

      def language_tool_reachable?
        return false unless language_tool_configured?

        address = instance.env['LANGUAGETOOL_ADDRESS']
        Rails.cache.fetch("echo:languagetool:reachable:#{address}", expires_in: 5.minutes) do
          LanguageToolService.reachable?(address)
        end
      end
    end
  end
end
