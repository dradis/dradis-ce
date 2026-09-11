module Dradis::CE::API
  module V3
    class EvidenceController < Dradis::CE::API::APIController
      include EventPublisher
      include Dradis::CE::API::ProjectScoped

      before_action :set_node

      def index
        @evidence = @node.evidence.order('updated_at desc')
        @evidence = @evidence.page(params[:page].to_i) if params[:page]
      end

      def show
        @evidence = @node.evidence.find(params[:id])
      end

      def create
        @evidence = @node.evidence.build(evidence_params)
        @evidence.author = current_user.email
        if @evidence.save
          publish_event('evidence.created', @evidence.to_event_payload)
          render status: 201, location: node_evidence_path(@node, @evidence)
        else
          render_validation_errors(@evidence)
        end
      end

      def update
        @evidence = @node.evidence.find(params[:id])
        if @evidence.update(evidence_params)
          publish_event('evidence.updated', @evidence.to_event_payload)
          render evidence: @evidence
        else
          render_validation_errors(@evidence)
        end
      end

      def destroy
        @evidence = @node.evidence.find(params[:id])
        @evidence.destroy
        publish_event('evidence.destroyed', @evidence.to_event_payload)
        render_successful_destroy_message
      end

      private

      def set_node
        @node = current_project.nodes.find(params[:node_id])
      end

      def evidence_params
        params.require(:evidence).permit(:content, :issue_id)
      end
    end
  end
end
