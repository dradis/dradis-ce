module Dradis::Plugins::Echo
  class Roslin
    class LanguageTool
      include Dradis::Plugins::Configurable

      DEFAULT_ADDRESS = 'http://localhost:8010'

      addon_settings :'echo-roslin-language-tool' do
        settings.default_address = DEFAULT_ADDRESS
        settings.default_enabled = false
      end

      def self.enabled?
        Roslin.enabled? && settings.enabled
      end

      def self.load_configuration(form)
        form.language_tool_address = settings.address.presence || DEFAULT_ADDRESS
        form.language_tool_enabled = settings.enabled
      end

      def self.save_configuration(form)
        settings.address = form.language_tool_address.presence || DEFAULT_ADDRESS
        settings.enabled = form.language_tool_enabled
        settings.save
      end
    end
  end
end
