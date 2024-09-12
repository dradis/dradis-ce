module TasksHelper
  TASKS_LIMIT = 5

  def assigned_cards(project_id = nil)
    @assigned_cards ||= begin
      # Using Arel.sql to sort the records by due_date with null due_date records last
      cards = current_user.cards.order(Arel.sql('due_date IS NULL, due_date ASC'))

      # params[:id] is used for projects#show widget
      if project_id
        cards.select { |card| card.project.id == current_project.id }
      else
        cards
      end
    end
  end

  def overflow_tasks_count
    return 0 unless assigned_cards.size > TASKS_LIMIT

    assigned_cards.size - TASKS_LIMIT
  end

  def due_date_badge(task)
    return unless task.due_date

    badge_class =
      case task.due_date
      when Date.today
        'bg-warning'
      when ->(date) { date < Date.today }
        'bg-danger'
      else
        'bg-success'
      end

    content_tag(:span, class: "badge-due-date badge #{badge_class}") do
      content_tag(:i, nil, class: 'fa-regular fa-clock me-1') +
      content_tag(:span, task.due_date.strftime('%b %e'))
    end
  end
end
