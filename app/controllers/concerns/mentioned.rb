module Mentioned
  extend ActiveSupport::Concern

  included do
    before_action :find_mentionable_users, only: [:index, :create, :update]
  end

  protected

  def find_mentionable_users
    @mentionable_users ||= begin
      Project.new.testers_for_mentions
    end
  end
end
