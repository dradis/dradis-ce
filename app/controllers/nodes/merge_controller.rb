# frozen_string_literal: true

class Nodes::MergeController < NodesController
  def create
    source_node = Node.find(params[:node_id])

    result = Nodes::Merger.call(params[:target_id], source_node) do
      Node.destroy(source_node.id)
    end

    respond_to do |format|
      format.html do
        if result.empty?
          target_node = Node.find(params[:target_id])
          redirect_to project_node_path(current_project, params[:target_id]), notice: "#{source_node.label} merged into #{target_node.label}."
        else
          redirect_to project_node_path(current_project, source_node.id), alert: 'Could not merge nodes.'
        end
      end
    end
  end
end
