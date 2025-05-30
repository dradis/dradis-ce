module Dradis::CE::API
  module V3
    class UploadController < Dradis::CE::API::APIController
      include Dradis::CE::API::ProjectScoped
      include Uploaded

      skip_before_action :json_required, only: [:create]

      def create
        filename = CGI::escape params[:file].original_filename
        # add the file as an attachment
        attachment = Attachment.new(filename, node_id: current_project.plugin_uploads_node.id)
        attachment << params[:file].read
        attachment.save

        if Rails.env.production? || (File.size(attachment.fullpath) > 1024 * 1024)
          @job_id = process_upload_background(attachment: attachment)
          @status = :queued
        else
          process_upload_inline(attachment: attachment)
          @status = :completed
        end
      end

      def show
        job = Resque::Plugins::Status::Hash.get(params[:job_id])

        if job
          @status = job.status
          @message = job.message
        else
          raise ActiveRecord::RecordNotFound
        end
      end

      private

      def job_logger
        @job_logger ||= Log.new
      end
    end
  end
end
