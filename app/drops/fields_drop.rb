class FieldsDrop < ::Liquid::Drop
  def initialize(fields)
    @fields = fields

    define_drop_methods
  end

  private

  def define_drop_methods
    @fields.each do |key, value|
      method_name = key.parameterize(separator: '_')
      define_singleton_method(method_name) { value }
      self.class.invokable_methods << method_name
    end
  end
end
