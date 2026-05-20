module Dradis::Plugins::Echo
  class ConfigurationForm
    include ActiveModel::Model

    def self.agents
      [Roslin]
    end

    # For each agent, define a getter and setter so the view can use fields_for
    # and the controller can mass-assign nested params in a single submitted form.
    # The setter handles two callers:
    #   - from_storage: passes an already-built ConfigurationForm, stored as-is
    #   - controller params: passes a raw hash, wrapped in ConfigurationForm.new
    agents.each do |agent|
      attr_reader agent.form_key

      define_method(:"#{agent.form_key}=") do |attrs|
        form_class = agent::ConfigurationForm
        instance_variable_set(:"@#{agent.form_key}", attrs.is_a?(form_class) ? attrs : form_class.new(attrs || {}))
      end
    end

    def self.from_storage
      instance = new
      agents.each do |agent|
        instance.public_send(:"#{agent.form_key}=", agent::ConfigurationForm.from_storage)
      end
      instance
    end

    validate :agent_forms_valid

    def save
      return false unless valid?

      self.class.agents.each do |agent|
        public_send(agent.form_key).save
      end
      true
    end

    private

    def agent_forms_valid
      self.class.agents.each do |agent|
        sub_form = public_send(agent.form_key)
        # sub_form is nil when ConfigurationForm.new is called without attrs,
        # because ActiveModel only calls the setter for keys present in the hash.
        next if sub_form.nil? || sub_form.valid?

        sub_form.errors.each do |error|
          errors.add(agent.form_key, error.message)
        end
      end
    end
  end
end
