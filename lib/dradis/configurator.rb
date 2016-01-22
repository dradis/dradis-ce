module Dradis
  class Configurator

    class << self

      alias_method :configurables, :subclasses

      # provide a simple way to set up various attributes of the configurator,
      # we provide a configure() method which accepts a hash of options and a
      # block, which will be evaluated in class scope, so we can do either:
      #
      #  class Configuration < Core::Configurator
      #     configure     :namespace => 'osvdb'
      #     configure_key :api_key, :default => "<your_API_key>", :type => :string
      #   end
      #
      # or
      #
      #   Configuration = Class.new(Core::Configurator).configure(:namespace => 'test') do
      #     configure_key :something, :default => 'xyz', :type => :string
      #   end
      def configure(options={}, &block)
        @namespace    ||= options[:namespace]

        self.instance_eval(&block) if block

        self
      end

      # set up configuration options for a key, allowing default values to be
      # set
      def setting(key, options={})
        @configs      ||= {}

        @configs[key] ||= {}
        @configs[key]   = @configs[key].merge(options)

        self
      end

      # retrieve a value given a key, grabbing the default value from the configurations
      # array
      def get(key)
        value     = Configuration.where(name: self.namespaced(key)).first.try(:value)

        if value.nil? && @configs[key][:default]
          if @configs[key][:default].is_a?(Proc)
            value = @configs[key][:default].call
          else
            value = @configs[key][:default]
          end
        end

        value
      end

      # determines whether or not a key exists as a configuration, either in the
      # database, or the definitions of default values
      def is_a_configuration?(key)
        Configuration.exists?(:name => self.namespaced(key)) || @configs && @configs.keys.include?(key)
      end

      # use method_missing to make configuration values appear as variables on
      # the class, i.e., Configuration.host would return the value called 'host'
      # in the current namespace
      #
      # this should be combined with #respond_to? or #try to sweep up errors caused
      # by undefined configurations
      def method_missing(sym, *attrs)
        is_a_configuration?(sym) ? get(sym) : super(sym, *attrs)
      end

      # determines the namespace that we should be using to scope configurations
      # for this object, by default we assume this to be derived from the full
      # class name (e.g., WikiImport::Configuration will result in a space of
      # wiki_import)
      def namespace
        @namespace || self.to_s.gsub(/::[^:]+\z/, '').underscore
      end

      def respond_to?(sym)
        is_a_configuration?(sym) || super(sym)
      end

      # settings are provided from two sources: anything defined by calling setting
      # on the class, and anything else in the configurator's namespace (ad-hoc)
      def settings
        @configs||= {}

        settings  = @configs.collect do |key,config|
          # If :default is nil, this returns nil. If it's a value, it's returned,
          # if it's a lambda it gets called.
          default_value = config[:default] && config[:default].is_a?(Proc) ? config[:default].call : config[:default]

          config_name = self.namespaced(key)
          Configuration.find_by_name(config_name) || Configuration.new(name: config_name, value: default_value)
        end

        settings += Configuration.where('name like ?', "#{self.namespace}:%")

        settings.uniq
      end

      def to_hash
        Hash[self.settings.collect { |setting| [setting.name, setting.value] }]
      end

      def try(sym, *attrs)
        self.send(sym, *attrs) rescue nil
      end


      protected
      # builds a correctly namespaced name, leaving the configuration name intact
      # if it is in global namespace, or adding 'namespace:' if we are namespaced
      def namespaced(name)
        self.namespace.nil? ? name.to_s.underscore : [self.namespace, name.to_s.underscore].join(":")
      end

    end
  end
end
