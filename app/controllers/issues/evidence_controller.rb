class Issues::EvidenceController < IssuesController
  before_action :set_issue, only: [:index]
  before_action :set_affected_nodes, only: [:index]

  EXTRA_COLUMNS = ['Created by', 'Created', 'Updated'].freeze
  SKIP_COLUMNS = ['Title', 'Label'].freeze

  def index
    @evidence_columns = ['Node'] | (collection_field_names(@issue.evidence) - SKIP_COLUMNS) | EXTRA_COLUMNS

    render layout: false
  end

  private

  def set_issue
    @issue = Issue.where(node_id: current_project.issue_library.id).find(params[:issue_id])
  end
end
