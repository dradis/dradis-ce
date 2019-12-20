module Dradis::CE::API
  module V1
    class AttachmentsController < Dradis::CE::API::APIController
      include ActivityTracking
      include Dradis::CE::API::ProjectScoped

      before_action :set_node

      skip_before_action :json_required, :only => [:create]

      def index
        @attachments = @node.attachments.each(&:close)
      end

      def show
        begin
          @attachment = Attachment.find(params[:filename], conditions: { node_id: @node.id } )
        rescue
          raise ActiveRecord::RecordNotFound, "Couldn't find attachment with filename '#{params[:filename]}'"
        end
      end

      def create
        uploaded_files = params.fetch(:files, [])

        @attachments = []
        uploaded_files.each do |uploaded_file|
          attachment_name = Attachment.available_name(@node, original: uploaded_file.original_filename)

          attachment = Attachment.new(attachment_name, node_id: @node.id)
          attachment << uploaded_file.read
          attachment.save

          @attachments << attachment
        end

        if @attachments.any? && @attachments.count == uploaded_files.count
          render status: 201
        else
          render status: 422
        end
      end

      def update
        attachment  = Attachment.find(params[:filename], conditions: { node_id: @node.id } )
        attachment.close

        begin
          new_name    = CGI::unescape(attachment_params[:filename])
          destination = Attachment.pwd.join(@node.id.to_s, new_name).to_s

          if !File.exist?(destination) && !destination.match(/^#{Attachment.pwd}/).nil?
            File.rename attachment.fullpath, destination
            @attachment = Attachment.find(new_name, conditions: { node_id: @node.id } )
          else
            raise "Destination file already exists"
          end
        rescue
          @attachment = attachment
          render status: 422
        end
      end

      def destroy
        @attachment = Attachment.find(params[:filename], conditions: { node_id: @node.id} )
        @attachment.delete

        render_successful_destroy_message
      end

      private

      def set_node
        @node = current_project.nodes.find(params[:node_id])
      end

      def attachment_params
        params.require(:attachment).permit(:filename)
      end
    end
  end
end
