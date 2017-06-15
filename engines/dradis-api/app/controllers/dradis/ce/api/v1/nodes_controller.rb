module Dradis::CE::API
  module V1
    class NodesController < Dradis::CE::API::V1::ProjectScopedController

      def index
        @nodes =
          if params[:page]
            Node.user_nodes.includes(:evidence, :notes, evidence: [:issue])
                .order('updated_at desc')
                .page(params[:page])
          else
            Node.user_nodes.includes(:evidence, :notes, evidence: [:issue])
                .order('updated_at desc')
          end
      end

      def show
        @node = Node.includes(:evidence, :notes, evidence: [:issue]).find(params[:id])
      end

      def create
        @node = Node.new(node_params)

        if @node.save
          track_created(@node)
          render status: 201, location: dradis_api.node_url(@node)
        else
          render_validation_errors(@node)
        end
      end

      def update
        @node = Node.find(params[:id])
        if @node.update_attributes(node_params)
          track_updated(@node)
          render node: @node
        else
          render_validation_errors(@node)
        end
      end

      def destroy
        node = Node.find(params[:id])
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
