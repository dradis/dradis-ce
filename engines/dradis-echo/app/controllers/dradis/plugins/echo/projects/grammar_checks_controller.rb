module Dradis::Plugins::Echo
  class Projects::GrammarChecksController < AuthenticatedController
    include ProjectScoped

    def create
      commentable_class = InlineCommentable.allowed_types
                            .find { |t| t == params[:commentable_type] }
                            &.constantize

      return head :unprocessable_entity unless commentable_class

      record   = commentable_class.find(params[:commentable_id])
      raw_text = record.respond_to?(:text) ? record.text : record.content
      fields   = FieldParser.source_to_fields(raw_text)

      matches = LanguageToolService.new(
        fields:  fields,
        address: Roslin::LanguageTool.settings.address
      ).call

      render json: matches
    rescue LanguageToolService::UnavailableError => e
      render json: { error: e.message }, status: :service_unavailable
    end
  end
end
