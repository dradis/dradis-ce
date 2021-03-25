class SubscriptionsController < AuthenticatedController
  def create
    subscription = Subscription.new(subscription_params)
    subscription.user = current_user
    subscription.save

    redirect_back fallback_location: root_path, notice: 'Subscribed!'
  end

  def destroy
    subscription = Subscription.find_by(
      user: current_user,
      subscribable_type: subscription_params[:subscribable_type],
      subscribable_id: subscription_params[:subscribable_id]
    )
    subscription.destroy

    redirect_back fallback_location: root_path, notice: 'Unsubscribed!'
  end

  private

  def subscription_params
    params.require(:subscription).permit(:subscribable_type, :subscribable_id)
  end
end
