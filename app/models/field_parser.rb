class FieldParser
  FIELDS_REGEX = /#\[(.+?)\]#[\r|\n](.*?)(?=#\[|\z)/m
  FIELDLESS_REGEX = /^([\s\S]*?)(?=\n{,2}#\[.+?\]#|\z)/

  # Convert serialized form data to Dradis-style item content.
  def self.fields_to_source(serialized_form)
    serialized_form.each_slice(2).map do |field_name, field_value|
      field = field_name[1]
      value = field_value[1]

      str = ''
      str << "#[#{field}]#\n" unless field.empty?
      str << "#{value}" unless value.empty?

      str
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

  # Field-less strings are strings that do not have a field header (#[Field]#).
  # This parses all characters before a field header or end of string.
  def self.parse_fieldless_string(source)
    source[FIELDLESS_REGEX, 1]
  end
end
