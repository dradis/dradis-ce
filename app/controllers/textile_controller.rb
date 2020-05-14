class TextileController < AuthenticatedController
  # Returns a single field for the form view
  def field
    @index = params[:index].to_i
  end

  # Returns the form view given a source text
  def form
    @form_data = Note.parse_fields(params[:source]) if params[:source]

    if fieldless_string && !fieldless_string.empty?
      @form_data = { '': fieldless_string }.merge(@form_data)
    end

    @allow_dropdown = JSON.parse(params[:allow_dropdown] || 'false')
  end

  # Returns the markup cheatsheet that is used by the jQuery.Textile plugin Help
  # button.
  def markup_help
    render layout: false
  end

  # Returns the source text given a form data
  def source
    render plain: convert_to_source(form_params)
  end

  # Returns the Textile version of a text passed as parameter
  def textilize
    @text =
      if params[:form]
        convert_to_source(form_params)
      else
        params[:text]
      end

    render layout: false
  end

  private

  # Convert serialized form data to Dradis-style item content
  def convert_to_source(form_data)
    form_data.each_slice(2).map do |field_name, field_value|
      field = field_name[1]
      value = field_value[1]

      str = ''
      str << "#[#{field}]#\n" unless field.empty?
      str << "#{value}" unless value.empty?

      str
    end.compact.join("\n\n")
  end

  # Reformatted form parameters to be dradified
  def form_params
    JSON.parse(params[:form]).map do |field|
      [field['key'], field['value']]
    end || []
  end

  # Field-less strings are strings that do not have a field header (#[Field]#).
  def fieldless_string
    # Extract all characters before a field header (#[Field]#)
    @fieldless_string ||= params[:source][/^([\s\S]*?)(?=\n{,2}#\[.+?\]#|\z)/, 1]
  end
end
