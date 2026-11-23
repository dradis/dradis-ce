# Streams a job's output to the console subscribed to its uid (see
# consoles/_console). Lines are broadcast as they are written and never
# saved, unlike Log.
#
# Broadcasts are sent synchronously, not with the *_later variants, so lines
# reach the console in the order they were written.
#
# The uid is the authorization primitive for the stream: only the user that
# started the job gets a page that subscribes to it, and Turbo signs the
# stream name so it can't be guessed from the uid alone.
class ConsoleLogger
  attr_reader :uid

  def self.dom_id(uid, part)
    "console_#{uid}_#{part}"
  end

  def self.stream_name(uid)
    [:console, uid]
  end

  def initialize(uid:)
    @uid = uid
  end

  def complete!
    broadcast_state(:completed)
  end

  def fail!
    broadcast_state(:failed)
  end

  def write(trace = nil)
    text = trace.nil? ? yield : trace

    broadcast do
      Turbo::StreamsChannel.broadcast_append_to(
        self.class.stream_name(uid),
        target: self.class.dom_id(uid, :lines),
        partial: 'consoles/line',
        locals: { text: text }
      )
    end
  end

  alias :debug :write
  alias :error :write
  alias :fatal :write
  alias :info :write
  alias :warn :write

  private

  # The console is only a live view of the job: if it can't be reached, log
  # it and let the job carry on.
  def broadcast
    yield
  rescue StandardError => e
    Rails.logger.warn("ConsoleLogger #{uid}: broadcast failed (#{e.class}: #{e.message})")
  end

  def broadcast_state(state)
    broadcast do
      Turbo::StreamsChannel.broadcast_replace_to(
        self.class.stream_name(uid),
        target: self.class.dom_id(uid, :status),
        partial: 'consoles/status',
        locals: { state: state, uid: uid }
      )
    end
  end
end
