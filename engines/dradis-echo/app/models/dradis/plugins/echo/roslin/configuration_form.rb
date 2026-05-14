module Dradis::Plugins::Echo
  class Roslin
    class ConfigurationForm < Agent::ConfigurationForm
      attribute :issue_interaction_enabled, :boolean
      attribute :issue_interaction_model
      attribute :issue_interaction_provider_id

      def self.components
        [
          Roslin,
          Roslin::IssueInteraction
        ]
      end

      validates :issue_interaction_provider_id, presence: true, if: :issue_interaction_enabled

      def self.permitted_params
        super + [
          :issue_interaction_enabled,
          :issue_interaction_model,
          :issue_interaction_provider_id
        ]
      end

      def self.from_storage
        instance = new
        components.each { |c| c.load_configuration(instance) }
        instance
      end

      def save
        return false unless valid?

        self.class.components.each { |c| c.save_configuration(self) }
        true
      end
    end
  end
end
