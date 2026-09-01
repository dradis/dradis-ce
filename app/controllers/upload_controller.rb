# The UploadController provides access to the different upload plugins that
# have been deployed in the dradis server.
#
# Each upload plugin will include itself in the Plugins::Upload module and this
# controller will include it so all the functionality provided by the different
# plugins is exposed.
#
# A convenience list method is provided that will return all the currently
# loaded plugins of this category.
class UploadController < AuthenticatedController
  include ProjectScoped
  include Uploadable

  # UPGRADE
  # include Plugins::Upload

  def index; end

  # TODO: this would overwrite an existing file with the same name.
  # See AttachmentsController#create
  def create
    filename = CGI::escape upload_params[:file].original_filename
    # add the file as an attachment
    @attachment = Attachment.new(filename, node_id: current_project.plugin_uploads_node.id)
    @attachment << upload_params[:file].read
    @attachment.save

    @success = true
    flash.now[:notice] = "Successfully uploaded #{ filename }"
  end

  def parse
    attachment = Attachment.find(upload_params[:file], conditions: { node_id: current_project.plugin_uploads_node.id })

    # Files smaller than 1Mb are processed inlined, others are
    # processed in the background via a Redis worker.
    #
    # In Production, play it save and use the worker (the Rules Engine can
    # cause the processing of a small file to time out).
    #
    # In Development and testing, if the file is small, process in line.
    job =
      if Rails.env.production? || (File.size(attachment.fullpath) > 1024 * 1024)
        process_upload_background(attachment: attachment)
      else
        process_upload_inline(attachment: attachment)
      end

    render json: { job_id: job.job_id }
  end

  private

  def job_logger
    @job_logger ||= Log.new(uid: upload_params[:item_id])
  end

  def upload_params
    params.permit(:file, :item_id, :uploader, :state)
  end
end
