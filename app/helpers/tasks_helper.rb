module TasksHelper
  def due_date_badge(task)
    return unless task.due_date

    case task.due_date
    when Date.today
      content_tag(:span, 'Today', class: 'badge-due-date badge bg-warning-dark')
    when Date.tomorrow
      content_tag(:span, 'Tomorrow', class: 'badge-due-date badge bg-warning')
    else
      due_date_class = task.due_date < Date.today ? 'badge-due-date badge bg-danger' : 'badge-due-date badge bg-success'
      content_tag(:span, task.due_date.strftime('%b %e'), class: due_date_class)
    end
  end

  def widget_task_class(task)
    return unless task.due_date

    case task.due_date
    when Date.today
      'due-today'
    when Date.tomorrow
      'due-tomorrow'
    else
      task.due_date < Date.today ? 'due-overdue' : 'due-future'
    end
  end

  def tasks_widget_limit
    3
  end
end
