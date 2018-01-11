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
        klass: item_class_name,
        uid: @job_logger.uid
      }

      if @count > @max_deleted_inline
        @job_logger.write 'Enqueueing multiple delete job to start in the background.'
        job = MultiDestroyJob.perform_later(job_params)
        @job_logger.write "Job id is #{job.job_id}."
      elsif @count > 0
        @job_logger.write 'Performing multiple delete job inline.'
        MultiDestroyJob.perform_now(job_params)
      end
    end
  end
end
