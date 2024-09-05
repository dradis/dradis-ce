module TasksHelper
  TASKS_LIMIT = 5

  def all_assigned_tasks
    @assigned_tasks ||= begin
      # Using Arel.sql to sort the records by due_date with null due_date records last
      tasks = current_user.cards.order(Arel.sql('due_date IS NULL, due_date ASC'))

      if params[:project_id]
        return tasks.select { |card| card.project.id == current_project.id }
      end

      tasks
    end
  end

  def assigned_tasks
    all_assigned_tasks.first(TASKS_LIMIT)
  end

  def overflow_tasks_count
    return unless all_assigned_tasks.size > TASKS_LIMIT

    all_assigned_tasks.size - TASKS_LIMIT
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
