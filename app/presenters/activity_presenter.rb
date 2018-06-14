class ActivityPresenter < ActionPresenter
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

  def trackable_title
    @title ||=
      if collection.respond_to?(:title) && collection.title?
        collection.title
      elsif collection.respond_to?(:label) && collection.label?
        collection.label
      end
  end
end
