module Dradis::CE::API
  module V1
    class IssuesController < Dradis::CE::API::APIController
      include ActivityTracking
      include Dradis::CE::API::ProjectScoped

      def index
        @issues  = current_project.issues.includes(:tags).sort
      end

      def show
        @issue = current_project.issues.find(params[:id])
      end

      def create
        @issue = current_project.issues.new(issue_params)
        @issue.author   = current_user.email
        @issue.category = Category.issue
        @issue.node     = current_project.issue_library

        if @issue.save
          track_created(@issue)
          @issue.tag_from_field_content!
          render status: 201, location: dradis_api.issue_url(@issue)
        else
          render_validation_errors(@issue)
        end
      end

      def update
        @issue = current_project.issues.find(params[:id])
        if @issue.update_attributes(issue_params)
          track_updated(@issue)
          render node: @node
        else
          render_validation_errors(@issue)
        end
      end

      def destroy
        @issue = current_project.issues.find(params[:id])
        @issue.destroy
        track_destroyed(@issue)
        render_successful_destroy_message
      end

      private
      def issue_params
        params.require(:issue).permit(:text)
      end
    end
  end
end
