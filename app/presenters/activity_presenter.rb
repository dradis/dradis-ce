class ActivityPresenter < ActionPresenter
  presents :activity
  belongs_to :trackable

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
      if belongs_to.respond_to?(:title) && belongs_to.title?
        belongs_to.title
      elsif belongs_to.respond_to?(:label) && belongs_to.label?
        belongs_to.label
      end
  end
end
