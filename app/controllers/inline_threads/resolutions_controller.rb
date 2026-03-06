class InlineThreads::ResolutionsController < AuthenticatedController
  include EventPublisher

  layout false

  before_action :set_thread

  def create
    @thread.resolve!(current_user)
    publish_event('inline_thread.resolved', @thread.to_event_payload)
  end

  def destroy
    @thread.reopen!(current_user)
    publish_event('inline_thread.reopened', @thread.to_event_payload)
  end

  private

  def set_thread
    @thread = InlineThread.find(params[:inline_thread_id])
  end
end
