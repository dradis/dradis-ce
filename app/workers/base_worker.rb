# Base class from which other Resque workers inherit. It makes sure that all DB
# connections are active (they could have timed out).
#
# See:
#   http://axonflux.com/resque-to-the-rescue-but-a-gotcha-dont-forget
#

class BaseWorker
  # All our workers will make use of the resque-status plugin
  include Resque::Plugins::Status

  # Main method for this class, it re-connects any stale AR connections and
  # delegates to the #perform_delegate() method to perform the actual work.
  def perform(*args)
    ActiveRecord::Base.verify_active_connections!
    perform_delegate(*args)
  end

  # Implementing workers will override this method.
  def perform_delegate(*args)
  end
end