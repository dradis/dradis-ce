# Each time a record is set we check whether its session has already timed out
# or not, based on last request time. If so, the record is logged out and
# redirected to the sign in page. Also, each time the request comes and the
# record is set, we set the last request time inside its scoped session to
# verify timeout in the following request.
#
# See:
#   https://github.com/hassox/warden/wiki/Callbacks#after_set_user
#   https://github.com/plataformatec/devise/blob/master/lib/devise/models/timeoutable.rb
#   https://github.com/plataformatec/devise/blob/master/lib/devise/hooks/timeoutable.rb
#

Warden::Manager.after_set_user do |user, warden, options|
  if user &&  warden.authenticated?
    last_request_at = warden.session['last_request_at']

    if last_request_at.is_a? Integer
      last_request_at = Time.at(last_request_at).utc
    elsif last_request_at.is_a? String
      last_request_at = Time.parse(last_request_at)
    end

    # When the app is initializing for the first time the DB is not available.
    @session_timeout ||= if ::Configuration.table_exists?
                        ::Configuration.session_timeout
                      else
                        15
                      end

    if last_request_at && last_request_at <= @session_timeout.minutes.ago
      warden.raw_session.inspect
      warden.logout
      throw :warden, message: "Session timed out!"
    end

    warden.session['last_request_at'] = Time.now.utc.to_i
  end
end
