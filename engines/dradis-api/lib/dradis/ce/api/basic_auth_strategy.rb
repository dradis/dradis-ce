module Dradis::CE::API
  class BasicAuthStrategy < ::Warden::Strategies::Base
    attr_reader :email, :password

    # This strategy should be applied when we are requesting /api/
    def valid?
      !!(request.path_info =~ /\A\/api\//)
    end

    def authenticate!
      if auth.provided? && auth.basic? && auth.credentials
        email = auth.credentials.first
        password = auth.credentials.last

        if ( !email.blank? && !password.nil? && user = User.enabled.authenticate(email, password) )
          success!(user)
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
      Rack::Response[
        status,
        {
          'Content-Type' => 'application/json',
          'WWW-Authenticate' => %(Basic realm="API")
        },
        [ { message: 'Requires authentication' }.to_json ]
      ].finish
    end

  end
end
