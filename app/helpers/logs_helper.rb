module LogsHelper
  def log_status_class(log)
    case log&.state
    when :completed
      'text-success'
    when :failed
      'text-error'
    when :running
      'text-warning'
    else
      'text-muted'
    end
  end

  def log_status_summary(log)
    case log&.state
    when :completed
      'Complete.'
    when :failed
      'Failed. See the log below for details.'
    when :running
      'Working…'
    else
      'Waiting to start'
    end
  end
end
