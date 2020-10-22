module EvidenceHelper
  def evidence_redirect_path(return_to)
    if return_to == 'issue'
      project_issue_path(current_project, @evidence.issue, tab: 'evidence-tab')
    elsif @evidence.persisted?
      [current_project, @node, @evidence]
    else
      [current_project, @node]
    end
  end
end
