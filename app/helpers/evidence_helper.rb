module EvidenceHelper
  def cancel_path(back_to)
    if back_to == 'issue'
      [current_project, @evidence.issue]
    elsif @evidence.persisted?
      [current_project, @node, @evidence]
    else
      [current_project, @node]
    end
  end
end
