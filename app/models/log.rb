class Log < ApplicationRecord
  # The console stops polling on either line. Write them with #complete!/#fail!
  COMPLETED = 'Worker process completed.'.freeze
  FAILED = 'Worker process failed.'.freeze

  after_initialize :set_uid

  def complete!
    write(COMPLETED)
  end

  def fail!
    write(FAILED)
  end

  def failed?
    text == FAILED
  end

  def finished?
    [COMPLETED, FAILED].include?(text)
  end

  # The UUID assigned here is the authorization primitive for reading
  # the log stream. It's returned only to the user that initiated the
  # job; ConsoleController#status treats possession of the UUID as the
  # authorization to read the associated records.
  def set_uid
    self.uid ||= SecureRandom.uuid
  end

  def write(trace = nil, &block)
    text = trace.nil? ? yield : trace
    Log.create!(attributes.except('id').merge(text: text))
  end

  alias :debug :write
  alias :error :write
  alias :fatal :write
  alias :info :write
  alias :warn :write

  def time
    created_at.strftime('%H:%M:%S')
  end

  def read
    text.gsub(/\e\[\d+m/, '')
  end

  def color
    color_num = text.match(/\e\[(\d+)m/)
    return '' unless color_num
    color_num[1]
  end
end
