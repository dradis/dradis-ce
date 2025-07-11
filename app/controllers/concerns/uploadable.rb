module Uploadable
  extend ActiveSupport::Concern

  included do
    include UploaderFinder

    before_action :validate_state, only: [:create, :parse]
  end

  private

  def process_upload_background(args = {})
    attachment = args[:attachment]

    # NOTE: call the bg job as last thing in the action helps us
    # avoid SQLite3::BusyException when using sqlite and
    # activejob async queue adapter
    UploadJob.perform_later(
      default_user_id: current_user.id,
      file: attachment.fullpath.to_s,
      plugin_name: @uploader.to_s,
      project_id: current_project.id,
      state: @state
    )
  end

  def process_upload_inline(args = {})
    attachment = args[:attachment]

    UploadJob.perform_now(
      default_user_id: current_user.id,
      file: attachment.fullpath.to_s,
      plugin_name: @uploader.to_s,
      project_id: current_project.id,
      state: @state
    )
  end

  def validate_state
    return if @uploader.to_s.include?('::Projects')

    if Issue.states.keys.include?(upload_params[:state])
      @state = upload_params[:state]
    elsif is_api?
      raise ActiveRecord::RecordNotFound
    else
      redirect_to project_upload_manager_path(current_project), alert: 'Something fishy is going on...'
    end
  end

  def is_api?
    controller_path.include?('api')
  end
end
