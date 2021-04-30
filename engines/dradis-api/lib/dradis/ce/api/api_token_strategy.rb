module Dradis::CE::API
  class ApiTokenStrategy < ::Warden::Strategies::Base
    attr_reader :email, :password

    # This strategy should be applied when we are requesting /api/
    def valid?
      !!(request.path_info =~ /\A\/api\//)
    end

    def authenticate!
      if token
        user = User.enabled.find_by_api_token(token)
        if user && secure_compare(user.api_token)
          success!(user)
        else
          custom!(unauthorized(403))
        end
      end
    end

    private
    def token
      @token ||= ActionController::HttpAuthentication::Token.token_and_options(ActionDispatch::Request.new(env)).first rescue nil
    end

    # Taken from [Devise](https://github.com/plataformatec/devise).
    # constant-time comparison algorithm to prevent timing attacks
    def secure_compare(a)
      b = token
      return false if a.blank? || b.blank? || a.bytesize != b.bytesize
      l = a.unpack "C#{a.bytesize}"

      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift  }
      res == 0
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
