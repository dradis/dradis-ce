module Dradis::CE::API
  module V3
    class UploadsController < Dradis::CE::API::APIController
      include Dradis::CE::API::ProjectScoped
      include Uploadable

      skip_before_action :json_required, only: [:create]
      before_action :set_tracker, only: [:show]

      def create
        filename = CGI::escape upload_params[:file].original_filename
        # add the file as an attachment
        attachment = Attachment.new(filename, node_id: current_project.plugin_uploads_node.id)
        attachment << upload_params[:file].read
        attachment.save

        @message = '(no message)'

        if Rails.env.production? || (File.size(attachment.fullpath) > 1024 * 1024)
          @job_id = process_upload_background(attachment: attachment).job_id
          @state = :queued
        else
          process_upload_inline(attachment: attachment)
          @job_id = :inline
          @state = :completed
        end
      end

      def show
        @state = @state_hash[:state]
        @message = @state_hash[:message] || '(no message)'
      end

      private

      def job_logger
        @job_logger ||= Log.new
      end

      def set_tracker
        @job_id = params[:id]
        tracker = JobTracker.new(job_id: @job_id, queue_name: UploadJob.queue_name)
        @state_hash = tracker.state

        raise ActiveRecord::RecordNotFound unless @state_hash[:state]
      end

      def upload_params
        params.permit(:file, :uploader, :state)
      end
    end
  end
end
