module Dradis::CE::API
  module V1
    class EvidenceController < Dradis::CE::API::APIController
      include ActivityTracking
      include Dradis::CE::API::ProjectScoped

      before_action :set_node

      def index
        @evidence = @node.evidence.all.order('updated_at desc')
      end

      def show
        @evidence = @node.evidence.find(params[:id])
      end

      def create
        @evidence = @node.evidence.build(evidence_params)
        if @evidence.save
          track_created(@evidence)
          render status: 201, location: node_evidence_path(@node, @evidence)
        else
          render_validation_errors(@evidence)
        end
      end

      def update
        @evidence = @node.evidence.find(params[:id])
        if @evidence.update_attributes(evidence_params)
          track_updated(@evidence)
          render evidence: @evidence
        else
          render_validation_errors(@evidence)
        end
      end

      def destroy
        @evidence = @node.evidence.find(params[:id])
        @evidence.destroy
        track_destroyed(@evidence)
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
