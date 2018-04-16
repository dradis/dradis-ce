class Issues::NodesController < IssuesController
  skip_before_action :find_or_initialize_issue

  def show
    issue = Issue.find(params[:issue_id])
    node  = Node.joins(:evidence)
                .select('nodes.id, label, type_id, count(evidence.id) as evidence_count')
                .where('evidence.issue_id = ? and nodes.id = ?', params[:issue_id], params[:id])
                .first
    render partial: 'issues/evidence_content',
           layout: false,
           locals: {
             node: node,
             instances: Evidence.where(issue: issue, node: node)
           }
  end
end
