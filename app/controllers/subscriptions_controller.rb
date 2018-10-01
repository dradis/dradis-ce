class SubscriptionsController < AuthenticatedController
  include ProjectScoped

  def create
    subscription = Subscription.new(subscription_params)
    subscription.user = current_user
    subscription.save

    redirect_to helpers.subscribable_path(subscription), notice: 'Subscribed!'
  end

  def destroy
    subscription = Subscription.find_by(
      user: current_user,
      subscribable_type: subscription_params[:subscribable_type],
      subscribable_id: subscription_params[:subscribable_id]
    )
    subscription.destroy

    redirect_to helpers.subscribable_path(subscription), notice: 'Unsubscribed!'
  end

  private

  def subscription_params
    params.require(:subscription).permit(:subscribable_type, :subscribable_id)
  end
end
