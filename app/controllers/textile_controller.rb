class TextileController < AuthenticatedController
  def form
    @form_data = Note.parse_fields(params[:form]) if params[:form]

    render layout: false
  end

  def source
    render plain: build_source
  end

  private

  def build_source
    form_data = JSON.parse(params[:form])

    form_data.each_slice(2).map do |field_name, field_value|
      field = field_name['value']
      value = field_value['value']
      next if field.empty? && value.empty?

      "#[#{field}]#\n#{value}"
    end.compact.join("\n\n")
  end
end
