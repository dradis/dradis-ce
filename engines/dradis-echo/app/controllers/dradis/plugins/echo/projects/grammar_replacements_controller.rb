module Dradis::Plugins::Echo
  class Projects::GrammarReplacementsController < AuthenticatedController
    include ProjectScoped

    def create
      commentable_class = InlineCommentable.allowed_types
                            .find { |t| t == params[:commentable_type] }
                            &.constantize

      return head :unprocessable_entity unless commentable_class

      record      = commentable_class.find(params[:commentable_id])
      field_name  = params[:field_name]
      offset      = params[:offset].to_i
      length      = params[:length].to_i
      replacement = params[:replacement]

      raw_text = record.respond_to?(:text) ? record.text : record.content
      new_raw  = apply_replacement(raw_text, field_name, offset, length, replacement)

      if record.respond_to?(:text)
        record.update!(text: new_raw)
      else
        record.update!(content: new_raw)
      end

      render json: { raw: new_raw }
    end

    private

    def apply_replacement(raw_text, field_name, offset, length, replacement)
      fields            = FieldParser.source_to_fields(raw_text)
      field_value       = fields[field_name]
      fields[field_name] = field_value[0, offset] + replacement + field_value[(offset + length)..]
      FieldParser.fields_hash_to_source(fields)
    end
  end
end
