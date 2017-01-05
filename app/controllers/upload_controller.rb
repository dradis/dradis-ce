# The UploadController provides access to the different upload plugins that
# have been deployed in the dradis server.
#
# Each upload plugin will include itself in the Plugins::Upload module and this
# controller will include it so all the functionality provided by the different
# plugins is exposed.
#
# A convenience list method is provided that will return all the currently
# loaded plugins of this category.
class UploadController < ProjectScopedController

  # UPGRADE
  # include Plugins::Upload

  before_action :find_uploaders
  before_action :find_uploads_node, only: [:create, :parse]
  before_action :validate_uploader, only: [:create, :parse]

  def index
    @last_job = Log.maximum(:uid) || 1
  end

  # TODO: this would overwrite an existing file with the same name.
  # See AttachmentsController#create
  def create
    filename = CGI::escape params[:file].original_filename
    # add the file as an attachment
    @attachment = Attachment.new(filename, node_id: @uploads_node.id)
    @attachment << params[:file].read
    @attachment.save

    @success = true
    @item_id = params[:item_id].to_i
    flash.now[:notice] = "Successfully uploaded #{ filename }"
  end

  def parse
    attachment = Attachment.find(params[:file], conditions: { node_id: @uploads_node.id })

    # Files smaller than 1Mb are processed inlined, others are
    # processed in the background via a Redis worker.
    #
    # In Production, play it save and use the worker (the Rules Engine can
    # cause the processing of a small file to time out).
    #
    # In Development and testing, if the file is small, process in line.
    if Rails.env.production? || (File.size(attachment.fullpath) > 1024*1024)
      process_upload_background(attachment: attachment)
    else
      process_upload_inline(attachment: attachment)
    end

    # Nothing to do, the client-side JS will poll ./status for updates
    # from now on
    head :ok
  end

  def status
    @logs = Log.where("uid = ? and id > ?", params[:item_id].to_i, params[:after].to_i)
    @uploading = !(@logs.last.text == 'Worker process completed.') if @logs.any?
  end


  private
  def job_logger
    @job_logger ||= Log.new(uid: params[:item_id].to_i)
  end

  def process_upload_background(args={})
    attachment = args.fetch(:attachment)

    @job_id = UploadProcessor.create(
                                    file:   attachment.fullpath.to_s,
                                    plugin: params[:uploader],
                                    uid:    params[:item_id])
    job_logger.write("Enqueueing job to start in the background. Job id is #{ @job_id }")
  end

  def process_upload_inline(args={})
    attachment = args[:attachment]

    job_logger.write('Small attachment detected. Processing in line.')
    begin
      content_service  = Dradis::Plugins::ContentService.new(plugin: @uploader)
      template_service = Dradis::Plugins::TemplateService.new(plugin: @uploader)

      importer = @uploader::Importer.new(
                  logger: job_logger,
         content_service: content_service,
        template_service: template_service
      )

      importer.import(file: attachment.fullpath)
    rescue Exception => e
      # Fail noisily in test mode; re-raise the error so the test fails:
      raise if Rails.env.test?
      job_logger.write('There was a fatal error processing your upload:')
      job_logger.write(e.message)
      if Rails.env.development?
        e.backtrace[0..10].each do |trace|
          job_logger.debug{ trace }
          sleep(0.2)
        end
      end
    end
    job_logger.write('Worker process completed.')
  end

  def find_uploaders
    # :upload plugins can define multiple uploaders
    @uploaders ||= Dradis::Plugins::with_feature(:upload).
                     collect(&:uploaders).
                     flatten.
                     sort_by(&:name)
  end

  def find_uploads_node
    @uploads_node = Node.plugin_uploads_node
  end

  # Ensure that the requested :uploader is valid and has been included in the
  # Plugins::Upload mixin
  def validate_uploader
    valid_uploaders = @uploaders.collect(&:name)

    if (params.key?(:uploader) && valid_uploaders.include?(params[:uploader]))
      @uploader = params[:uploader].constantize
    else
      redirect_to upload_manager_path, alert: 'Something fishy is going on...'
    end
  end

end
