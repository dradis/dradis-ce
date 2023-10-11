module Turbo
  module Redirection
    extend ActiveSupport::Concern
    # in order to have Turbo work with the old-style XMLHttpRequests issued by UJS, 
    # you'll need to shim the old Turbolinks behavior that made those requests compatible with 302s 
    # (by invoking Turbolinks, now Turbo, directly)
    # See https://github.com/hotwired/turbo-rails/blob/main/UPGRADING.md#2-replace-the-turbolinks-gem-in-gemfile-with-turbo-rails
    def redirect_to(url = {}, options = {})
      turbo = options.delete(:turbo)

      super.tap do
        if turbo != false && request.xhr? && !request.get?
          visit_location_with_turbo(location, turbo)
        end
      end
    end

    private
    def visit_location_with_turbo(location, action)
      visit_options = {
        action: action.to_s == 'advance' ? action : 'replace'
      }

      self.status = 200
      self.response_body = "Turbo.visit(#{location.to_json}, #{visit_options.to_json})"
      response.content_type = 'text/javascript'
      response.headers['X-Xhr-Redirect'] = location
    end
  end
end
