module Dradis::Plugins::Echo
  class Projects::GrammarReplacementsController < AuthenticatedController
    include ProjectScoped

    before_action :set_record

    def create
      field_name  = params[:field_name]
      offset      = params[:offset].to_i
      length      = params[:length].to_i
      replacement = params[:replacement]

      return head :unprocessable_entity if replacement.nil?

      raw_text = params[:text].presence ||
                 (@record.respond_to?(:text) ? @record.text : @record.content)
      fields   = FieldParser.source_to_fields(raw_text)

      return head :unprocessable_entity unless fields[field_name]

      field_value = fields[field_name]
      return head :unprocessable_entity if offset < 0 || (offset + length) > field_value.length

      new_raw = apply_replacement(raw_text, field_name, offset, length, replacement)

      attr = @record.respond_to?(:text) ? :text : :content
      unless @record.update(attr => new_raw)
        return render json: { errors: @record.errors.full_messages }, status: :unprocessable_entity
      end

      render json: { raw: new_raw }
    end

    private

    def apply_replacement(raw_text, field_name, offset, length, replacement)
      fields             = FieldParser.source_to_fields(raw_text)
      field_value        = fields[field_name]
      fields[field_name] = field_value[0, offset] + replacement + field_value[(offset + length)..]
      FieldParser.fields_hash_to_source(fields)
    end

    def set_record
      commentable_class = InlineCommentable.allowed_types
                            .find { |t| t == params[:commentable_type] }
                            &.constantize

      return head :unprocessable_entity unless commentable_class

      @record = current_project.send(commentable_class.model_name.plural).find(params[:commentable_id])
    end
  end
end
