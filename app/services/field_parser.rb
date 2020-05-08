module FieldParser
  REGEX = /#\[(.+?)\]#[\r|\n](.*?)(?=#\[|\z)/m

  # Parse the contents of the field and split it to return a Hash of field
  # name/value pairs. Field / values are defined using this syntax:
  #
  #   #[Title]#
  #   This is the value of the Title field
  #
  #   #[Description]#
  #   Lorem ipsum...
  #
  def parse_fields(string)
    Hash[ *string.scan(REGEX).flatten.map(&:strip) ]
  end
end
