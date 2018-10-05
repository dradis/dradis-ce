module Subscribed
  extend ActiveSupport::Concern

  included do
    before_action :find_subscription, only: :show
  end

  protected

  def find_subscription
    subscribable = instance_variable_get("@#{controller_name.singularize}")
    @subscription = subscribable.subscription_for(user: current_user)
  end
end
