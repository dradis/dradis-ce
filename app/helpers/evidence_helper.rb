module EvidenceHelper
  def evidence_redirect_path(return_to)
    if return_to == 'issue'
      [current_project, @evidence.issue]
    elsif @evidence.persisted?
      [current_project, @node, @evidence]
    else
      [current_project, @node]
    end
  end
end
