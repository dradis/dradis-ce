# frozen_string_literal: true

# This controller is used by the console_updater js to retrieve logs
# for a specific job.
#
# The job UUID is the authorization primitive: it's generated server-side
# via SecureRandom.uuid (see Log#set_uid) and only returned to the user
# that initiated the job. Possession of a valid UUID is treated as the
# authorization to read the associated log stream -- we do not scope
# Log records to a user or project at the row level.
class ConsoleController < AuthenticatedController
  def status
    @job_id = params[:item_id]
    @logs = Log.where(
      'uid = ? and id > ?',
      @job_id, params[:after].to_i
    )
    @working = @logs.last.text != 'Worker process completed.' if @logs.any?
  end
end
