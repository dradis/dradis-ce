# frozen_string_literal: true

class Nodes::MergeController < NodesController
  def create
    target_node = Node.find(params[:target_id])

    source_node = Nodes::Merger.call(target_node, @node)

    respond_to do |format|
      format.html do
        if source_node.destroyed?
          redirect_to project_node_path(current_project, params[:target_id]), notice: "#{@node.label} merged into #{target_node.label}."
        else
          redirect_to project_node_path(current_project, source_node.id), alert: 'Could not merge nodes.'
        end
      end
    end
  end
end
