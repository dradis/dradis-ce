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
  include Uploaded

  # UPGRADE
  # include Plugins::Upload

  def index; end

  # TODO: this would overwrite an existing file with the same name.
  # See AttachmentsController#create
  def create
    filename = CGI::escape params[:file].original_filename
    # add the file as an attachment
    @attachment = Attachment.new(filename, node_id: current_project.plugin_uploads_node.id)
    @attachment << params[:file].read
    @attachment.save

    @success = true
    @item_id = Log.new.uid + 1
    flash.now[:notice] = "Successfully uploaded #{ filename }"
  end

  def parse
    attachment = Attachment.find(params[:file], conditions: { node_id: current_project.plugin_uploads_node.id })

    # Files smaller than 1Mb are processed inlined, others are
    # processed in the background via a Redis worker.
    #
    # In Production, play it save and use the worker (the Rules Engine can
    # cause the processing of a small file to time out).
    #
    # In Development and testing, if the file is small, process in line.
    if Rails.env.development? || (File.size(attachment.fullpath) > 1024 * 1024)
      process_upload_background(attachment: attachment)
    else
      process_upload_inline(attachment: attachment)
    end

    # Nothing to do, the client-side JS will poll ./status for updates
    # from now on
    head :ok
  end

  private

  def job_logger
    @job_logger ||= Log.new(uid: params[:item_id].to_i)
  end
end
