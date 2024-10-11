class FieldParser
  FIELDS_REGEX = /#\[(.+?)\]#[\r|\n](.*?)(?=#\[|\z)/m
  HEADERLESS_REGEX = /^([\s\S]*?)(?=\n{,2}#\[.+?\]#|\z)/

  # Convert serialized form data to Dradis-style item content.
  def self.fields_to_source(serialized_form)
    serialized_form.each_slice(2).map(&to_source).compact.join("\n\n")
  end

  # Convert a hash of field name/value pairs to Dradis-style item content.
  def self.fields_hash_to_source(fields)
    fields.map(&to_source).compact.join("\n\n")
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
  # If the string contains a headerless field, it will be prepended to
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

    headerless_fields = parse_fields_without_headers(string)

    if headerless_fields.present?
      array.prepend(['', headerless_fields])
    end

    array
  end

  # Headerless fields are strings that do not have a field header (#[Field]#).
  # This parses all characters before a field header or end of string.
  def self.parse_fields_without_headers(source)
    source[HEADERLESS_REGEX, 1]
  end

  private

  def self.to_source
    return Proc.new do |field, value|
      field = field.is_a?(String) ? field.to_s : field[:value]
      value = value.is_a?(String) ? value.to_s : value[:value]

      str = ''
      str << "#[#{field}]#\n" unless field.empty?
      str << value unless value.empty?

      str
    end
  end
end
