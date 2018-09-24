# This service helps create tags which have complex
# rules for naming. See comment in Tag model
class TagNamer
  attr_accessor :name, :color, :user, :group

  def initialize(name:, color: nil, user: nil, group: nil)
    @name = name
    @color = color
    @user = user
    @group = group
  end

  def execute
    if valid_color?
      prepend_to_name(color.gsub('#', '!'))
    elsif valid_user?
      prepend_to_name("@#{user}")
    elsif group
      prepend_to_name("##{group}")
    end

    return name
  end

  private

  def valid_color?
    color =~ /^#([A-Fa-f0-9]{6})$/i
  end

  def valid_user?
    User.where(email: user).exists?
  end

  def prepend_to_name(value)
    @name = "#{value}_#{name}"
  end
end