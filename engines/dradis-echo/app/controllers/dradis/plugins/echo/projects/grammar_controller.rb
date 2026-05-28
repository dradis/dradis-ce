module Dradis::Plugins::Echo
  class Projects::GrammarController < AuthenticatedController
    include ProjectScoped

    before_action :set_record

    private

    def set_record
      commentable_class = InlineCommentable.allowed_types
                            .find { |t| t == params[:commentable_type] }
                            &.constantize

      return head :unprocessable_entity unless commentable_class

      @record = current_project.send(commentable_class.model_name.plural).find_by(id: params[:commentable_id])

      head :not_found unless @record
    end
  end
end
