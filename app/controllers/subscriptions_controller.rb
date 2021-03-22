class SubscriptionsController < AuthenticatedController
  layout false

  before_action :validate_subscribable, only: [:index, :create]

  helper_method :current_user_subscription, :subscribable, :subscriptions

  def index; end

  def create
    subscription = Subscription.new(subscription_params)
    subscription.user = current_user
    subscription.save

    redirect_back fallback_location: root_path, notice: 'Subscribed!'
  end

  def destroy
    current_user_subscription.destroy

    redirect_back fallback_location: root_path, notice: 'Unsubscribed!'
  end

  private

  def current_user_subscription
    @current_user_subscription ||= subscribable.subscription_for(user: current_user)
  end

  def subscribable
    @subscribable ||= begin
      case params[:action]
      when 'index', 'create', 'destroy'
        Subscription.new(subscription_params).subscribable
      else
        raise 'Invalid action'
      end
    end
  end

  def subscription_params
    case params[:action]
    when 'index'
      params.permit(:subscribable_id, :subscribable_type)
    when 'create', 'destroy'
      params.require(:subscription).permit(:subscribable_id, :subscribable_type)
    else
      raise 'Invalid action'
    end
  end

  def subscriptions
    @subscriptions ||= subscribable.subscriptions.includes(:user)
  end

  def validate_subscribable
    unless subscribable.respond_to?(:subscriptions)
      raise 'Invalid subscribable'
    end
  end
end
