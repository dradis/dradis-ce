# Dradis::API::WardenStrategy
#
# HTTP Basic authentication strategy for Warden.
#
# See:
#   https://github.com/hassox/warden
#
module Dradis::CE::API
  class WardenStrategy < ::Warden::Strategies::Base

    attr_reader :email, :password

    # This strategy should be applied when we are requesting /api/
    def valid?
      !!(request.path_info =~ /\A\/api\//)
    end

    def authenticate!
      if auth.provided? && auth.basic? && auth.credentials
        username = auth.credentials.first
        password = auth.credentials.last

        if not ( username.blank? || password.nil? || ::BCrypt::Password.new(::Configuration.shared_password) != password )
          success!(username)
        else
          custom!(unauthorized(403))
        end
      else
        custom!(unauthorized(401))
      end
    end

    private

    def auth
      @auth ||= Rack::Auth::Basic::Request.new(env)
    end

    def unauthorized(status=401)
      Rack::Response.new(
        [JSON.generate({message: 'Requires authentication'})],
        status,
        {
          'Content-Type'     => 'application/json',
          'Content-Length'   => '0',
          'WWW-Authenticate' => %(Basic realm="API")
        }
      )
    end

  end
end
