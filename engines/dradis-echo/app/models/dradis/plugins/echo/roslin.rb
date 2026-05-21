module Dradis::Plugins::Echo
  class Roslin
    include Dradis::Plugins::Configurable
    extend Agent

    addon_settings :'echo-roslin'

    def self.enabled?
      ActiveModel::Type::Boolean.new.cast(settings.enabled)
    end

    def self.load_configuration(form)
      form.enabled = settings.enabled
    end

    def self.save_configuration(form)
      settings.enabled = form.enabled
      settings.save
    end
  end
end
