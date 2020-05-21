class FieldParser
  FIELDS_REGEX = /#\[(.+?)\]#[\r|\n](.*?)(?=#\[|\z)/m

  # Convert serialized form data to Dradis-style item content.
  def self.fields_to_source(serialized_form)
    serialized_form.each_slice(2).map do |field_name, field_value|
      field = field_name[:value]
      value = field_value[:value]
      next if field.empty?

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
  def self.source_to_fields(string)
    Hash[ *string.scan(FIELDS_REGEX).flatten.map(&:strip) ]
  end
end
