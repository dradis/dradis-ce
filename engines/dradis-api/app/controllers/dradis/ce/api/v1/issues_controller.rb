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
        @issue = current_project.issues.new
        @issue.author   = current_user.email
        @issue.category = Category.issue
        @issue.node     = current_project.issue_library

        if is_valid_state? &&
            (@issue.assign_attributes(issue_params) || @issue.valid?)
          @issue.save
          track_created(@issue)
          @issue.tag_from_field_content!
          render status: 201, location: dradis_api.issue_url(@issue)
        else
          render_validation_errors(@issue)
        end
      end

      def update
        @issue = current_project.issues.find(params[:id])

        if is_valid_state? && @issue.update_attributes(issue_params)
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

      # We validate the state params here, otherwise it will throw an ArgumentError
      # SEE: https://github.com/rails/rails/issues/13971
      def is_valid_state?
        if issue_params[:state] && !Issue.states.keys.include?(issue_params[:state])
          @issue.errors.add(:state, 'is not valid.')
          return false
        end

        true
      end

      def issue_params
        params.require(:issue).permit(:text, :state)
      end
    end
  end
end
