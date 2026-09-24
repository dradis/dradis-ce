module LogsHelper
  def log_status_class(log)
    case log&.state
    when :completed
      'text-success'
    when :failed
      'text-error'
    else
      'text-primary'
    end
  end

  def log_status_summary(log)
    case log&.state
    when :completed
      'Import complete.'
    when :failed
      'Import failed. See the log below for details.'
    else
      'Importing…'
    end
  end
end
