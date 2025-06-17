module TasksHelper
  TASKS_LIMIT = 5

  def overflow_tasks_count(tasks)
    return 0 unless tasks.size > TASKS_LIMIT

    tasks.size - TASKS_LIMIT
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
