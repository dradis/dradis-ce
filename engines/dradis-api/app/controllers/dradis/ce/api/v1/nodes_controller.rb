module Dradis::CE::API
  module V1
    class NodesController < Dradis::CE::API::APIController
      include ActivityTracking
      include Dradis::CE::API::ProjectScoped

      def index
        @nodes = current_project.nodes.user_nodes.includes(:evidence, :notes, evidence: [:issue]).order('updated_at desc')
      end

      def show
        @node = current_project.nodes.includes(:evidence, :notes, evidence: [:issue]).find(params[:id])
      end

      def create
        @node = current_project.nodes.new(node_params)

        if @node.save
          track_created(@node)
          render status: 201, location: dradis_api.node_url(@node)
        else
          render_validation_errors(@node)
        end
      end

      def update
        @node = current_project.nodes.find(params[:id])
        if @node.update_attributes(node_params)
          track_updated(@node)
          render node: @node
        else
          render_validation_errors(@node)
        end
      end

      def destroy
        node = current_project.nodes.find(params[:id])
        node.destroy
        track_destroyed(node)
        render_successful_destroy_message
      end

      protected

      def node_params
        params.require(:node).permit(:label, :type_id, :parent_id, :position)
      end
    end
  end
end
