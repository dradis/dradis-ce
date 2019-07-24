# frozen_string_literal: true

class Nodes::MergeController < NodesController
  def create
    target_node = Node.find(params[:target_id])

    result = Nodes::Merger.call(target_node, @node)

    respond_to do |format|
      format.html do
        if result.empty?
          redirect_to project_node_path(current_project, params[:target_id]), notice: "#{@node.label} merged into #{target_node.label}."
        else
          redirect_to project_node_path(current_project, source_node.id), alert: 'Could not merge nodes.'
        end
      end
    end
  end
end
