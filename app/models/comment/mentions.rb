module Comment::Mentions
  extend ActiveSupport::Concern

  MENTION_PATTERN = /[a-z0-9][a-z0-9\-@\.]*/.freeze

  class_methods do
    def mentionable_users(resource, extra_scope = nil)
      base_scope = User.enabled
      scope = extra_scope ? base_scope.merge(extra_scope) : base_scope

      if resource.is_a?(Project)
        scope.merge(resource.testers_for_mentions)
      elsif resource.respond_to?(:project)
        scope.merge(resource.project.testers_for_mentions)
      else
        ids = scope.select do |user|
          Ability.new(user).can?(:read, resource)
        end.map(&:id)

        scope.where(id: ids)
      end
    end
  end

  def mentions
    @mentions = nil if content_changed?
    @mentions ||= begin
      emails = []
      HTML::Pipeline::MentionFilter.mentioned_logins_in(content, MENTION_PATTERN) do |_, login, _|
        emails << login
      end

      self.class.mentionable_users(commentable, User.where(email: emails.uniq))
    end
  end

  private

  def subscribe_mentioned
    mentions.each do |mention|
      Subscription.subscribe(user: mention, to: commentable)
    end
  end
end
