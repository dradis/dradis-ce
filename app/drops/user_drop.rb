class UserDrop < Liquid::Drop
  def initialize(user)
    @user = user
  end

  def name
    @user.name
  end

  def email
    @user.email
  end
end
