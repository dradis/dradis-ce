class Issues::NodesController < AuthenticatedController
  include ProjectScoped

  def show
    @node =
      Node.joins(:evidence)
          .select('nodes.id, label, type_id,
                  count(evidence.id) as evidence_count, nodes.updated_at')
          .where('evidence.issue_id = ? and nodes.id = ?',
                 params[:issue_id], params[:id])
          .first
    @instances = Evidence.where(issue_id: params[:issue_id], node: @node)

    render layout: false
  end
end
