module Dradis::Plugins::Echo
  module Agents
    # Convenience wrapper so callers can use Agents::Roslin.enabled? instead
    # of scattering Agent.find_by lookups across controllers, views, and jobs.
    module Roslin
      extend self

      DEFAULT_ENV = {
        'LANGUAGETOOL_ADDRESS' => LanguageToolService::DEFAULT_ADDRESS
      }.freeze
      NAME = 'Roslin'.freeze

      def exists?
        Agent.exists?(agent_type: :system, name: NAME)
      end

      def instance
        Agent.find_by!(agent_type: :system, name: NAME)
      end

      def provision!
        if exists?
          clear_legacy_configuration!
          return instance
        end

        agent = Agent.find_or_initialize_by(name: NAME)

        if agent.persisted? && !agent.system?
          agent.errors.add(:agent_type, 'must be system')
          raise ActiveRecord::RecordInvalid, agent
        end

        agent.assign_attributes(
          agent_type: :system,
          enabled: legacy_enabled,
          env: DEFAULT_ENV.dup,
          provider: provision_provider!
        )
        agent.save!

        clear_legacy_configuration!
        agent
      end

      delegate :id, :model_override, :provider, to: :instance

      def enabled?
        instance.enabled?
      rescue ActiveRecord::RecordNotFound
        false
      end

      def language_tool_configured?
        instance.env['LANGUAGETOOL_ADDRESS'].present?
      rescue ActiveRecord::RecordNotFound
        false
      end

      def language_tool_reachable?
        return false unless language_tool_configured?

        address = instance.env['LANGUAGETOOL_ADDRESS']
        Rails.cache.fetch("echo:languagetool:reachable:#{address}", expires_in: 5.minutes) do
          LanguageToolService.reachable?(address)
        end
      end

      private

      def clear_legacy_configuration!
        Configuration.where('name LIKE ?', 'echo:roslin_%').delete_all
      end

      def config_value(key)
        Configuration.find_by(name: "echo:#{key}")&.value
      end

      def legacy_enabled
        config_value('roslin_enabled') != 'false'
      end

      def provision_provider!
        Provider::Ollama.find_or_create_by!(name: 'Ollama') do |provider|
          provider.address = config_value('roslin_ollama_address') || Provider::Ollama::DEFAULT_ADDRESS
          provider.model = config_value('roslin_ollama_model') || Provider::Ollama::DEFAULT_MODEL
        end
      end
    end
  end
end
