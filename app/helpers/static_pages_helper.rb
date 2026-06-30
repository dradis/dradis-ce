module StaticPagesHelper
  def issue_bar_color(issue)
    issue.tags.first&.color || 'var(--untagged-color)'
  end

  def delta_icon(delta)
    case
    when delta > 0 then 'fa-arrow-up'
    when delta < 0 then 'fa-arrow-down'
    else 'fa-arrows-up-down'
    end
  end

  def tag_options(tags)
    [
      [
        'All',
        nil,
        { data: {
          'combobox-option-color': 'var(--text-default)',
          'combobox-option-icon': 'fa-solid fa-tags'
        } }
      ]
    ] + tags.uniq(&:name).map do |tag|
      [
        tag.display_name,
        tag.name,
        {
          data: {
            'combobox-option-color': tag.color,
            'combobox-option-icon': 'fa-solid fa-tag'
          }
        }
      ]
    end
  end
end
