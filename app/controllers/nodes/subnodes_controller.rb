# frozen_string_literal: true

class Nodes::SubnodesController < AuthenticatedController
  include ProjectScoped

  def new
    @parent = current_project.nodes.find(params[:node_id])

    # Only the add subnode modal's Turbo Frame requests this action
    render layout: false
  end
end
