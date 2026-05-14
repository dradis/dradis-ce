module Dradis::Plugins::Echo
  class Roslin
    class LanguageTool
      include Dradis::Plugins::Configurable

      addon_settings :'echo-roslin-language-tool' do
        settings.default_address = 'http://localhost:8010'
        settings.default_enabled = false
      end

      def self.enabled?
        Roslin.enabled? && settings.enabled
      end

      def self.load_configuration(form)
        form.language_tool_address = settings.address
        form.language_tool_enabled = settings.enabled
      end

      def self.save_configuration(form)
        settings.address = form.language_tool_address
        settings.enabled = form.language_tool_enabled
        settings.save
      end
    end
  end
end
