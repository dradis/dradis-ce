module MultipleDestroy
  extend ActiveSupport::Concern

  def multiple_destroy
    # cache these values
    @count = params[:ids].size
    @max_deleted_inline = ::Configuration.max_deleted_inline

    if @count > 0
      @job_logger = Log.new
      job_params = {
        author_email: current_user.email,
        ids: params[:ids],
        klass: klass_for_multiple_destroy,
        uid: @job_logger.uid
      }
      job_params[:project_id] = current_project.id if defined?(current_project)

      if @count > @max_deleted_inline
        @job_logger.write 'Enqueueing multiple delete job to start in the background.'
        job = MultiDestroyJob.perform_later(**job_params)
        @job_logger.write "Job id is #{job.job_id}."
      elsif @count > 0
        @job_logger.write 'Performing multiple delete job inline.'
        MultiDestroyJob.perform_now(**job_params)
      end
    end
  end

  private

  # Extracting this to a method so it can be overridden in controllers
  # fully qualified class name is needed for engine controllers
  def klass_for_multiple_destroy
    controller_name.singularize.capitalize
  end
end
