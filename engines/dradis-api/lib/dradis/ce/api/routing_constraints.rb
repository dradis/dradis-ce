module Dradis::CE::API
  # This class inspects the HTTP headers looking for the Accept header to
  # identify the version of the API the client is trying to use.
  #
  # See:
  #   http://railscasts.com/episodes/350-rest-api-versioning
  #   http://freelancing-gods.com/posts/versioning_your_ap_is
  #   http://developer.github.com/v3/mime/
  class RoutingConstraints
    def initialize(options)
      @version = options[:version]
      @default = options[:default]
    end

    def matches?(req)
      @default || req.headers['Accept'].include?("application/vnd.dradisapi; v=#{@version}")
    end
  end
end
