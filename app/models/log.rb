class Log < ApplicationRecord
  after_initialize :set_uid

  def set_uid
    self.uid ||= (Log.maximum(:uid) || 0) + 1
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

  def read
    "[#{created_at.strftime('%H:%M:%S')}]  #{text}"
  end
end
