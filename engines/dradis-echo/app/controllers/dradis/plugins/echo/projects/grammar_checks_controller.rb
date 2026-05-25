module Dradis::Plugins::Echo
  class Projects::GrammarChecksController < AuthenticatedController
    include ProjectScoped

    before_action :set_record

    def create
      raw_text = params[:text].presence ||
                 (@record.respond_to?(:text) ? @record.text : @record.content)
      fields   = FieldParser.source_to_fields(raw_text)

      matches = LanguageToolService.new(
        fields:  fields,
        address: Dradis::Plugins::Echo::Agents::Roslin.instance.env['LANGUAGETOOL_ADDRESS']
      ).call

      render json: matches
    rescue LanguageToolService::UnavailableError => e
      render json: { error: e.message }, status: :service_unavailable
    end

    private

    def set_record
      commentable_class = InlineCommentable.allowed_types
                            .find { |t| t == params[:commentable_type] }
                            &.constantize

      return head :unprocessable_entity unless commentable_class

      @record = current_project.send(commentable_class.model_name.plural).find(params[:commentable_id])
    end
  end
end
