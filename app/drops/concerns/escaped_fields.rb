module EscapedFields
  def fields
    @record.fields.transform_values { |value| CGI::escapeHTML(value) }
  end
end
