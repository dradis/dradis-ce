module Dradis::Plugins::Echo
  class Agent::ConfigurationForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :enabled, :boolean
    attribute :provider_id

    def self.permitted_params
      [:enabled, :provider_id]
    end
  end
end
