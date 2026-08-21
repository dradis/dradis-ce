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

    @wrapping = true

    original_method = instance_method(method_name)

    define_method(method_name) do |*args, &block|
      result = original_method.bind(self).call(*args, &block)
      self.class.sanitize(result)
    end

    @wrapping = false
  end

  def self.sanitize(obj)
    return obj if obj.nil? || !obj.is_a?(String) || obj.empty?

    HTML::LiquidSafeSanitizer.call(obj)
  end
end
