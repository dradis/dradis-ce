class FieldParser
  FIELDS_REGEX = /#\[(.+?)\]#[\r|\n](.*?)(?=#\[|\z)/m
  FIELDLESS_REGEX = /^([\s\S]*?)(?=\n{,2}#\[.+?\]#|\z)/

  # Convert serialized form data to Dradis-style item content.
  def self.fields_to_source(serialized_form)
    serialized_form.each_slice(2).map do |field_name, field_value|
      field = field_name[:value]
      value = field_value[:value]

      str = ''
      str << "#[#{field}]#\n" unless field.empty?
      str << "#{value}" unless value.empty?

      str
    end.compact.join("\n\n")
  end

  # Convert a hash of field name/value pairs to Dradis-style item content.
  def self.fields_hash_to_source(fields)
    fields.map do |field, value|
      value = value.to_s

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

  # Parse the contents of the field and split it to return an array of field
  # name/value pairs. Field / values are defined using this syntax:
  #
  #   #[Title]#
  #   This is the value of the Title field
  #
  #   #[Description]#
  #   Lorem ipsum...
  #
  # If the string contains a fieldless string, it will be prepended to
  # the result. E.g.
  #
  #   Line 1
  #   Line 2
  #
  #   #[Title]#
  #   This is the value of the Title field
  #
  #   => [["", "Line 1\nLine2"], "Title", "This is the value of the Title field"]
  #
  def self.source_to_fields_array(string)
    array = string.scan(FIELDS_REGEX).map do |field|
      field.map(&:strip)
    end

    fieldless_string = parse_fieldless_string(string)

    if fieldless_string.present?
      array.prepend(['', fieldless_string])
    end

    array
  end

  # Field-less strings are strings that do not have a field header (#[Field]#).
  # This parses all characters before a field header or end of string.
  def self.parse_fieldless_string(source)
    source[FIELDLESS_REGEX, 1]
  end
end
