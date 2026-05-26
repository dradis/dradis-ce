module Dradis::Plugins::Echo
  class Projects::GrammarCorrectionsController < Projects::GrammarController
    def create
      return head :service_unavailable unless Agents::Roslin.enabled? && Agents::Roslin.language_tool_configured?

      field_name = params[:field_name]
      offset = params[:offset].to_i
      length = params[:length].to_i
      replacement = params[:replacement]

      return head :unprocessable_entity if replacement.nil?

      raw_text = params.key?(:text) ? params[:text].to_s : @record.content
      fields = FieldParser.source_to_fields(raw_text)

      return head :unprocessable_entity unless (field_value = fields[field_name])
      return head :unprocessable_entity if offset < 0 || (offset + length) > field_value.length

      exact = params[:exact]
      return head :conflict if exact && field_value[offset, length] != exact

      new_raw = apply_replacement(field_name, length, offset, raw_text, replacement)

      unless params[:persist] == 'false'
        unless @record.update(content: new_raw)
          return render json: { errors: @record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      render json: { raw: new_raw }
    end

    private

    def apply_replacement(field_name, length, offset, raw_text, replacement)
      fields = FieldParser.source_to_fields(raw_text)
      field_value = fields[field_name]
      fields[field_name] = field_value[0, offset] + replacement + field_value[(offset + length)..]
      FieldParser.fields_hash_to_source(fields)
    end
  end
end
