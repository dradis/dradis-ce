module Dradis::CE::API
  module V1
    class IssuesController < APIController
      def index
        issuelib = Node.issue_library
        @issues  = Issue.where(node_id: issuelib.id).includes(:tags).sort
      end

      def show
        @issue = Issue.find(params[:id])
      end

      def create
        @issue = Issue.new(issue_params)
        if @issue.save
          render status: 201, location: dradis_ce_api.issue_url(@issue)
        else
          render_validation_error
        end
      end

      def update
        if !@issue.update_attributes(issue_params)
          render_validation_error
        end
      end

      private
      def issue_params
        params.require(:issue).permit(:text)
      end
    end
  end
end
