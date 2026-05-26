module Dradis::Plugins::Echo
  class Projects::GrammarSuggestionsController < Projects::GrammarController
    def create
      return head :service_unavailable unless Agents::Roslin.enabled? && Agents::Roslin.language_tool_configured?

      raw_text = params.key?(:text) ? params[:text].to_s : @record.content

      fields = FieldParser.source_to_fields(raw_text)

      matches = LanguageToolService.new(
        fields: fields,
        address: Agents::Roslin.instance.env['LANGUAGETOOL_ADDRESS']
      ).call

      render json: matches
    rescue LanguageToolService::UnavailableError => e
      render json: { error: e.message }, status: :service_unavailable
    end
  end
end
