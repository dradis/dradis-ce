module Dradis::Plugins::Echo
  module ProvidersHelper
    PROVIDER_ICONS = {
      'Anthropic' => 'dradis/plugins/echo/anthropic.svg',
      'Gemini' => 'dradis/plugins/echo/gemini.svg',
      'Ollama' => 'dradis/plugins/echo/ollama.svg',
      'OpenAI' => 'dradis/plugins/echo/openai.svg'
    }.freeze

    def provider_icon_path(provider)
      PROVIDER_ICONS.fetch(provider.type_name, 'dradis/plugins/echo/ollama.svg')
    end

    def provider_in_use?(provider)
      provider_used_by(provider).present?
    end

    def provider_used_by(provider)
      usages = []
      if Roslin::IssueInteraction.settings.provider_id.to_s == provider.id.to_s
        usages << 'Issue Interaction'
      end
      usages.join(', ')
    end
  end
end
