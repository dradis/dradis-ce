module TasksHelper
  def assigned_tasks
    @assigned_tasks ||= begin
      current_user.cards
        # Using Arel.sql to sort the records by due_date with null due_date records last
        .order(Arel.sql('due_date IS NULL, due_date ASC'))
        .select { |card| card.project.id == current_project.id }
    end
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
