# This controller is used by the console_updater js to retrieve logs
# for a specific job
class ConsoleController < ProjectScopedController
  def status
    @logs = Log.where(
      'uid = ? and id > ?',
      params[:item_id].to_i, params[:after].to_i
    )
    @working = @logs.last.text != 'Worker process completed.' if @logs.any?
  end
end
