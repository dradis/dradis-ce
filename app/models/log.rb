class Log < ApplicationRecord

  def write(trace=nil, &block)
    text = trace.nil? ? yield : trace
    Log.create!(attributes.merge({:text => text}))
  end

  alias :info :write
  alias :debug :write
  alias :error :write
  alias :fatal :write

  def read
    "[#{created_at.strftime('%H:%M:%S')}]  #{text}"
  end
end
