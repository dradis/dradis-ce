module ConfigurationMacros
  extend ActiveSupport::Concern

  def self.included(base)
    base.before(:each) do
      ::Configuration.create(
        name: 'admin:analytics',
        value: 'true'
      )
    end
  end
end
