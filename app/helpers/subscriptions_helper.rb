module SubscriptionsHelper
  def subscribable_path(subscription)
    polymorphic_path(
      commentable_resource_array(subscription.subscribable)
    )
  end

  private

  def subscribable_resource_array(subscribable)
    # FIXME - ISSUE/NOTE INHERITANCE
    # Would like to use only `commentable.respond_to?(:node)` here, but
    # that would return a wrong path for issues
    if subscribable.respond_to?(:node) && !subscribable.is_a?(Issue)
      [current_project, subscribable.node, subscribable]
    else
      [current_project, subscribable]
    end
  end
end
