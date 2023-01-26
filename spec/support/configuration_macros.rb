module ConfigurationMacros
  extend ActiveSupport::Concern

  def create_configuration(name, value)
    ::Configuration.create(
      name: name,
      value: value
    )
  end
end
