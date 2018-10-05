module Mentioned
  extend ActiveSupport::Concern

  included do
    before_action :find_mentionable_users, only: [:show]
  end

  protected

  def find_mentionable_users
    @mentionable_users = User.all
  end
end
