class FieldParser
  REGEX = /#\[(.+?)\]#[\r|\n](.*?)(?=#\[|\z)/m

  # Convert serialized form data to Dradis-style item content
  def self.convert_to_source(form_data)
    form_data.each_slice(2).map do |field_name, field_value|
      field = field_name[1]
      value = field_value[1]
      next if field.empty? || (field.empty? && value.empty?)

      "#[#{field}]#\n#{value}"
    end.compact.join("\n\n")
  end

  # Parse the contents of the field and split it to return a Hash of field
  # name/value pairs. Field / values are defined using this syntax:
  #
  #   #[Title]#
  #   This is the value of the Title field
  #
  #   #[Description]#
  #   Lorem ipsum...
  #
  def self.parse_fields(string)
    Hash[ *string.scan(REGEX).flatten.map(&:strip) ]
  end
end
