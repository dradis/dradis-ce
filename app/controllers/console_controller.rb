# frozen_string_literal: true

# This controller is used by the console_updater js to retrieve logs
# for a specific job
class ConsoleController < AuthenticatedController
  def status
    @job_id = params[:item_id].to_i
    @logs = Log.where(
      'uid = ? and id > ?',
      @job_id, params[:after].to_i
    )
    @working = @logs.last.text != 'Worker process completed.' if @logs.any?
  end
end
