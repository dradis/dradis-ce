class Log < ApplicationRecord
  after_initialize :set_uid
  after_create_commit :broadcast_log

  TERMINAL_STATES = {
    'Worker process completed.' => :completed,
    'Worker process failed.' => :failed
  }.freeze

  # The current status of a job's log: the terminal line if the job has
  # already finished (regardless of whether a later, non-terminal line
  # was written after it, e.g. by the controller after an inline-executed
  # job returns), otherwise the most recent line, otherwise a blank
  # placeholder for a job that hasn't logged anything yet.
  def self.latest_for(uid)
    where(uid: uid, text: TERMINAL_STATES.keys).last ||
      where(uid: uid).last ||
      new(uid: uid)
  end

  # The UUID assigned here is the authorization primitive for reading
  # the log stream. It's returned only to the user that initiated the
  # job; ConsoleController#status treats possession of the UUID as the
  # authorization to read the associated records. The same UUID is what
  # Turbo signs into the stream name broadcast_log below writes to, so a
  # broadcast subscription carries the same bearer-token security model
  # as the polling endpoint.
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

  def state
    TERMINAL_STATES.fetch(text, :running)
  end

  private

  # Subscribers: the upload console (upload/create.js.erb) and the
  # bulk-delete modal (datatable/delete.js). Anything else still polling
  # ConsoleController#status is unaffected, since this only pushes to
  # clients actually subscribed to this uid's stream.
  def broadcast_log
    Turbo::StreamsChannel.broadcast_append_to(uid, targets: console_selector('console'), partial: 'logs/log', locals: { log: self })
    Turbo::StreamsChannel.broadcast_replace_to(uid, targets: console_selector('status'), partial: 'logs/status', locals: { log: self }) unless state == :running
  end

  def console_selector(behavior)
    "[data-behavior~=#{behavior}][data-console-uid=\"#{uid}\"]"
  end
end
