module Dradis::CE::API
  module V3
    class UploadController < Dradis::CE::API::APIController
      include Dradis::CE::API::ProjectScoped

      skip_before_action :json_required, only: [:create]

      before_action :find_uploaders
      before_action :validate_uploader, only: [:create]

      def create
        filename = CGI::escape params[:file].original_filename
        # add the file as an attachment
        attachment = Attachment.new(filename, node_id: current_project.plugin_uploads_node.id)
        attachment << params[:file].read
        attachment.save

        @job_id = process_upload_background(attachment: attachment).job_id
      end

      def show
      end

      private

      def job_logger
        @job_logger ||= Log.new
      end

      def find_uploaders
        @uploaders ||= Dradis::Plugins::with_feature(:upload).
                         collect(&:uploaders).
                         flatten.
                         sort_by(&:name)
      end

      def process_upload_background(args = {})
        attachment = args.fetch(:attachment)

        job_logger.write 'Enqueueing job to start in the background.'

        UploadJob.perform_later(
          default_user_id: current_user.id,
          file: attachment.fullpath.to_s,
          plugin_name: @uploader.to_s,
          project_id: current_project.id,
          state: @state,
          uid: job_logger.id
        )
      end

      def validate_uploader
        valid_uploaders = @uploaders.collect(&:name)

        if (params.key?(:uploader) && valid_uploaders.include?(params[:uploader]))
          @uploader = params[:uploader].constantize
        else
          render status: 404
        end
      end
    end
  end
end
