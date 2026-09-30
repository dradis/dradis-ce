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
      'Import complete.'
    when :failed
      'Import failed. See the log below for details.'
    when :running
      'Importing…'
    else
      'Waiting for an upload'
    end
  end
end
