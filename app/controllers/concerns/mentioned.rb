module Mentioned
  extend ActiveSupport::Concern

  included do
    before_action :find_mentionable_users, only: [:index, :create, :update]
  end

  protected

  def find_mentionable_users
    @mentionable_users ||= begin
      if commentable.respond_to?(:project)
        project = commentable.project
        authorize! :use, project

        project.testers_for_mentions.enabled
      else
        User.enabled.includes(:permissions).select do |user|
          user_ability = Ability.new(user)
          user_ability.can?(:read, commentable)
        end
      end
    end
  end
end
