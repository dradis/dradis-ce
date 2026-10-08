module Dradis::CE::API
  module V3
    class NodesController < Dradis::CE::API::APIController
      include EventPublisher
      include Dradis::CE::API::ProjectScoped

      def index
        @nodes = current_project.nodes.user_nodes.includes(:evidence, :notes, evidence: [:issue]).order('updated_at desc')
        @nodes = @nodes.page(params[:page].to_i) if params[:page]
      end

      def show
        @node = current_project.nodes.includes(:evidence, :notes, evidence: [:issue]).find(params[:id])
      end

      def create
        @node = current_project.nodes.new(node_params)

        if @node.save
          publish_event('node.created', @node.to_event_payload)
          render status: 201, location: dradis_api.node_url(@node)
        else
          render_validation_errors(@node)
        end
      end

      def update
        @node = current_project.nodes.find(params[:id])
        if @node.update(node_params)
          publish_event('node.updated', @node.to_event_payload)
          render node: @node
        else
          render_validation_errors(@node)
        end
      end

      def destroy
        node = current_project.nodes.find(params[:id])
        node.destroy
        publish_event('node.destroyed', node.to_event_payload)
        render_successful_destroy_message
      end

      protected

      def node_params
        params.require(:node).permit(:label, :type_id, :parent_id, :position, :raw_properties)
      end
    end
  end
end
