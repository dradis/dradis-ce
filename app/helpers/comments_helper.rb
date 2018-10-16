module CommentsHelper
  def format_comment(text)
    simple_format(text).gsub(/@[a-z0-9\-_\.@]+/i) do |mention|
      user = User.find_by_email(mention[1..-1])
      if user
        content_tag :span, class: 'format_comment' do
          avatar_image(user, size: 30) +
          content_tag(:strong, user.email)
        end
      else
        mention
      end
    end.html_safe
  end
end
