module Mentionable
  extend ActiveSupport::Concern

  protected

  def find_mentionable_users
    @mentionable_users = User.all
  end
end
