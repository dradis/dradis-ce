module Dradis::CE::API
  module V3
    class UploadController < Dradis::CE::API::APIController
      include Dradis::CE::API::ProjectScoped
      include Uploaded

      skip_before_action :json_required, only: [:create]

      def create
        filename = CGI::escape upload_params[:file].original_filename
        # add the file as an attachment
        attachment = Attachment.new(filename, node_id: current_project.plugin_uploads_node.id)
        attachment << upload_params[:file].read
        attachment.save

        if Rails.env.production? || (File.size(attachment.fullpath) > 1024 * 1024)
          @job_id = process_upload_background(attachment: attachment).job_id
          @status = :queued
        else
          process_upload_inline(attachment: attachment)
          @status = :completed
        end
      end

      def show
        tracker = JobTracker.new(job_id: params[:job_id], queue_name: 'dradis_upload')
        status_hash = tracker.get_status

        if status_hash[:status]
          @status = status_hash[:status]
          @message = status_hash[:message]
        else
          raise ActiveRecord::RecordNotFound
        end
      end

      private

      def job_logger
        @job_logger ||= Log.new
      end

      def upload_params
        params.permit(:file, :uploader, :state)
      end
    end
  end
end
