module Dradis::CE::API
  module V1
    class NodesController < ProjectScopedController

      def index
        @nodes = Node.user_nodes.includes(:evidence, :notes, evidence: [:issue]).order('updated_at desc')
      end

      def show
        @node = Node.includes(:evidence, :notes, evidence: [:issue]).find(params[:id])
      end

      def create
        @node = Node.new(node_params)

        if @node.save
          render status: 201, location: dradis_api.node_url(@node)
        else
          render_validation_error
        end
      end

      def update
        if !@node.update_attributes(node_params)
          render_validation_error
        end
      end

      protected
      def node_params
        params.require(:node).permit(:label, :type_id, :parent_id, :position)
      end
    end
  end
end
