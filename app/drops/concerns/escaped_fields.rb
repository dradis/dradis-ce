module EscapedFields
  def fields
    @record.fields.transform_values do |value|
      BaseDrop.sanitize(value)
    end
  end
end
