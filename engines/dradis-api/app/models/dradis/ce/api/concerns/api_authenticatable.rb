module Dradis::CE::API::Concerns::APIAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_create :generate_api_token

    # Don't validate on create or the callback which generates an API token
    # will never be run:
    validates_presence_of :api_token, on: :update

    # TODO: this is using the old-style token generation (not encrypted), because
    # changing it would require other changes in the Profile page, API
    # authentication filter, etc.
    def generate_api_token(length: 20)
      result  = nil
      rlength = (length * 3) / 4

      loop do
        result = SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'zyxs')
        break unless User.find_by(api_token: result)
      end

      self.api_token = result
    end
  end

end
