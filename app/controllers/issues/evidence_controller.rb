class Issues::EvidenceController < IssuesController
  before_action :set_issue, only: [:index]
  before_action :set_affected_nodes, only: [:index]

  def index
    @evidence_columns = ['Node'] | all_evidence_columns | ['Created by', 'Created',  'Updated']

    render layout: false
  end

  def new
    @issues = Issue.where(node_id: current_project.issue_library.id)
    @issue = @issues.find(params[:issue_id])

    @nodes_for_add_evidence = current_project.nodes.user_nodes.order(:label)

    @template_content = template_content if params[:template]
  end

  private

  def all_evidence_columns
    @issue.evidence
          .map { |evidence| evidence.fields.keys }
          .flatten
          .uniq - ['Title', 'Label']
  end

  def set_auto_save_key
    @auto_save_key =  if params[:template]
      "project-#{current_project.id}-issue-#{params[:issue_id]}-evidence-#{params[:template]}"
    else
      "project-#{current_project.id}-issue-#{params[:issue_id]}-evidence"
    end
  end

  def set_issue
    @issue = Issue.where(node_id: current_project.issue_library.id).find(params[:issue_id])
  end
end
