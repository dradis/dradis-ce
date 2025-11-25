module Dradis::Plugins::Echo
  class ConfigurationForm
    include ActiveModel::Model

    attr_accessor :address, :model

    validates :address, allow_blank: false, presence: true, format: { with: URI.regexp(['http', 'https']), message: 'needs to be a valid URL' }
    validates :model, allow_blank: false, presence: true

    def self.from_storage
      instance = new
      [:address, :model].each do |setting|
        instance.send("#{setting}=", Engine.settings.send(setting))
      end
      instance
    end

    def save
      if valid?
        save_settings
      else
        false
      end
    end

    def configured?
      @configured ||= !Engine.settings.is_default?(:model, model)
    end

    private

    def save_settings
      [:address, :model].each do |setting|
        Engine.settings.send("#{setting}=", send(setting))
      end
      Engine.settings.save
    end
  end
end
