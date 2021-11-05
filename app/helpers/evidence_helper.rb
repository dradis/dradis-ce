module EvidenceHelper
  def evidence_redirect_path(return_to)
    if return_to == 'issue'
      [current_project, @evidence.issue]
    elsif @evidence.persisted?
      # @evidence.node_id might have changed (via Move) and can't
      # use the [] notation without an additional query to reload
      # the new Node.
      project_node_evidence_path(project_id: current_project.id, node_id: @evidence.node_id, id: @evidence.id)
    else
      [current_project, @node]
    end
  end
end
