module Dradis::Plugins::Echo
  class Roslin
    class IssueInteraction
      include Dradis::Plugins::Configurable

      addon_settings :'echo-roslin-issue-interaction' do
        settings.default_enabled = true
        # if model override isn't set, provider will use its default
        settings.default_model = nil
        settings.default_provider_id = nil
      end

      def self.model
        settings.model.presence
      end

      def self.provider
        Provider.find(settings.provider_id)
      end

      def self.enabled?
        Roslin.enabled? && ActiveModel::Type::Boolean.new.cast(settings.enabled)
      end

      def self.load_configuration(form)
        form.issue_interaction_enabled = settings.enabled
        form.issue_interaction_model = settings.model
        form.issue_interaction_provider_id = settings.provider_id
      end

      def self.save_configuration(form)
        settings.enabled = form.issue_interaction_enabled
        settings.model = form.issue_interaction_model
        settings.provider_id = form.issue_interaction_provider_id
        settings.save
      end
    end
  end
end
