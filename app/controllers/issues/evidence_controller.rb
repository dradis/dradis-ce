class Issues::EvidenceController < IssuesController
  def new
    @issues = Issue.where(node_id: current_project.issue_library.id)
    @issue = @issues.find(params[:issue_id])

    @nodes_for_add_evidence = current_project.nodes.user_nodes.order(:label)

    @template_content = template_content if params[:template]
  end

  private

  def set_auto_save_key
    @auto_save_key =  if params[:template]
      "project-#{current_project.id}-issue-#{params[:issue_id]}-evidence-#{params[:template]}"
    else
      "project-#{current_project.id}-issue-#{params[:issue_id]}-evidence"
    end
  end
end
