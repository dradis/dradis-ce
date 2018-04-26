class Issues::NodesController < IssuesController
  skip_before_action :find_or_initialize_issue

  def show
    issue = Issue.find(params[:issue_id])
    @node = Node.joins(:evidence)
                .select('nodes.id, label, type_id, count(evidence.id) as evidence_count')
                .where('evidence.issue_id = ? and nodes.id = ?', params[:issue_id], params[:id])
                .first
    @instances = Evidence.where(issue: issue, node: @node)

    render layout: false
  end
end
