class InlineThreads::ResolutionsController < AuthenticatedController
  include EventPublisher

  layout false

  load_and_authorize_resource :inline_thread

  def create
    @inline_thread.resolve!(current_user)
    publish_event('inline_thread.resolved', @inline_thread.to_event_payload)
  end

  def destroy
    @inline_thread.reopen!(current_user)
    publish_event('inline_thread.reopened', @inline_thread.to_event_payload)
  end

  private

  # Override EventPublisher#event_action_payload to use semantic action
  # names ('resolved'/'reopened') instead of the RESTful controller actions
  # ('create'/'destroy') so the activity feed shows the correct verb.
  #
  # FIXME: Replace with ActivityService action registration once
  # convention-over-configuration approach is implemented.
  def event_action_payload
    action_map = { 'create' => 'resolve', 'destroy' => 'reopen' }
    super.merge(action: action_map.fetch(action_name, action_name))
  end
end
