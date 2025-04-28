class BaseDrop < Liquid::Drop
  delegate :id, to: :@record

  def initialize(record)
    @record = record
  end

  # Override every method drop and if a method returns a string, escape it.
  def self.method_added(method_name)
    # NOTE: Since `define_method` also calls this method, the `define_method`
    # call below will trigger a recursion. We can prevent that by using the
    # @wrapping flag. If @wrapping == true, then we're inside the `define_method`
    # call below and we want to skip this. Otherwise, proceed as normal.
    return if @wrapping

    # Skip this if we're in the #escape method
    return if method_name == :escape

    @wrapping = true

    original_method = instance_method(method_name)

    define_method(method_name) do |*args, &block|
      result = original_method.bind(self).call(*args, &block)
      escape(result)
    end

    @wrapping = false
  end

  private

  def escape(string)
    if string.nil? ||
        !string.is_a?(String) ||
        string.empty?

      return string
    end

    CGI::escapeHTML(string)
  end
end
