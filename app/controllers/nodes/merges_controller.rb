# frozen_string_literal: true

class Nodes::MergesController < NodesController
  def create
    old_node = Node.find(params[:id])

    MergeNode.new(old_node, @node).execute

    redirect_to [current_project, @node]
  end
end
