class SubscriptionsController < AuthenticatedController
  before_action :authorize_subscribable

  layout false

  def index
    @subscriptions = subscribable.subscriptions.includes(:user)
    @subscribers = @subscriptions.filter_map(&:user)

    # Used for showing/hiding subscribe and unsubscribe links
    @subscription = @subscriptions.find { |subscription| subscription.user == current_user }
  end

  def create
    subscribe

    redirect_to subscriptions_path(subscription: subscription_params)
  end

  def destroy
    unsubscribe

    redirect_to subscriptions_path(subscription: subscription_params)
  end

  private

  def authorize_subscribable
    authorize! :read, subscribable.try(:project) || subscribable
  end

  # Ignores duplicates if they already subscribed, e.g. in another tab
  def subscribe
    Subscription.subscribe(user: current_user, to: subscribable)
  end

  def subscribable
    @subscribable ||= subscribable_class.find(subscription_params[:subscribable_id])
  end

  def subscribable_class
    if Subscribable.allowed_types.include?(subscription_params[:subscribable_type])
      subscription_params[:subscribable_type].constantize
    else
      raise 'Invalid subscribable'
    end
  end

  def subscription_params
    params.require(:subscription).permit(:subscribable_type, :subscribable_id)
  end

  def unsubscribe
    subscription = Subscription.find_by(
      user: current_user,
      subscribable_type: subscription_params[:subscribable_type],
      subscribable_id: subscription_params[:subscribable_id]
    )
    # Nothing to do if they already unsubscribed, e.g. in another tab
    subscription&.destroy
  end
end
