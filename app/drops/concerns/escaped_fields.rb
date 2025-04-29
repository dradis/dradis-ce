module EscapedFields
  def fields
    @record.fields.transform_values do |value|
      HTML::Pipeline::SanitizationFilter.call(value).to_s
    end
  end
end
