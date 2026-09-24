class Log < ApplicationRecord
  after_initialize :set_uid
  after_create_commit :broadcast_log

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
    case text
    when 'Worker process completed.' then :completed
    when 'Worker process failed.' then :failed
    else :running
    end
  end

  private

  # PoC scope: only the Import consumer subscribes to this stream today
  # (see upload/create.js.erb). Other consumers keep polling
  # ConsoleController#status until they're migrated too.
  def broadcast_log
    Turbo::StreamsChannel.broadcast_append_to(uid, targets: '[data-behavior~=console]', partial: 'logs/log', locals: { log: self })
    Turbo::StreamsChannel.broadcast_replace_to(uid, targets: '[data-behavior~=status]', partial: 'logs/status', locals: { log: self }) unless state == :running
  end
end
