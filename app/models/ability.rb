class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    can [:read, :use, :update], Project, authors: { id: [user.id] }
    can [:publish], Project do |project|
      # Allow all to publish if there are no reviewers
      project.reviewers.include?(user) || project.reviewers.count == 0
    end
    can [:create, :read], Comment
    can [:update, :destroy], Comment, user_id: user.id
    can :manage, Tag
  end
end
