module SubscriptionsHelper
  def subscription_params_for(subscribable)
    { subscribable_type: subscribable.class.to_s, subscribable_id: subscribable.id }
  end
end
