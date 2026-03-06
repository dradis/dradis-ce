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
end
