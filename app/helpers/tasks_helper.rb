module TasksHelper
  def due_date_badge(task)
    return unless task.due_date

    case task.due_date
    when Date.today
      content_tag(:span, 'Today', class: 'due-today')
    when Date.tomorrow
      content_tag(:span, 'Tomorrow', class: 'due-tomorrow')
    else
      due_date_class = task.due_date < Date.today ? 'due-overdue' : 'due-later'
      content_tag(:span, task.due_date.strftime('%b %e'), class: due_date_class)
    end
  end
end
