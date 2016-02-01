# Usage:
#   validates :json_attribute, presence: true, json: true
class JsonValidator < ActiveModel::EachValidator

  def initialize(options)
    options.reverse_merge!(message: :invalid)
    super(options)
  end

  def validate_each(record, attribute, value)
    return if not value.is_a?(String)
    value = value.strip
    ActiveSupport::JSON.decode(value)
  rescue JSON::ParserError => exception
    record.errors.add(options[:attribute] || attribute, options[:message], message: exception.message)
  end

end
