class SubscriptionsController < AuthenticatedController
  before_action :authorize_subscribable

  def create
    subscribe

    render_header_or_redirect(notice: 'Subscribed!')
  end

  def destroy
    unsubscribe

    render_header_or_redirect(notice: 'Unsubscribed!')
  end

  private

  def authorize_subscribable
    authorize! :read, subscribable.try(:project) || subscribable
  end

  # The comments header submits inside a Turbo Frame, so it only needs the
  # header back. Plain requests keep the redirect.
  def render_header_or_redirect(notice:)
    if turbo_frame_request?
      render partial: 'subscriptions/header', locals: {
        subscribable: subscribable,
        subscriptions: subscribable.subscriptions.includes(:user)
      }
    else
      redirect_back fallback_location: root_path, notice: notice
    end
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
