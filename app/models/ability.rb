class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    can [:update, :destroy], Comment, user_id: user.id
  end
end
