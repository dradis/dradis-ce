class ActivityPresenter < RecordPresenter
  presents :activity
  collection :trackable

  def title
    [
      linked_email,
      verb,
      linked_model
    ].join(' ').html_safe
  end

  private

  def partial_paths
    [
      "activities/#{collection_type.underscore}/#{activity.action}",
      "activities/#{collection_type.underscore}",
      'activities/activity'
    ]
  end

  def trackable_title
    @title ||=
      if collection.respond_to?(:title) && collection.title?
        collection.title
      elsif collection.respond_to?(:label) && collection.label?
        collection.label
      end
  end
end
