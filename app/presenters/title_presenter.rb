class TitlePresenter < BasePresenter
  presents :item

  def title
    if item.is_a?(Evidence)
      [
        h.colored_icon_for_model(item, 'fa-flag', 'list-item-icon'),
        item.issue.title
      ].join(' ').html_safe
    else
      item.title
    end
  end
end
