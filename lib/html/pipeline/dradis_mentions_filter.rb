module HTML
  class Pipeline
    # HTML Filter that replaces mentions with avatar images and names
    #
    # Context options:
    #   mentionable_users: The list of possible users to match from
    #
    #   username_pattern: The regex used to find and replace logins
    #
    #   view_context: Needed to render the avatars
    class DradisMentionsFilter < HTML::Pipeline::MentionFilter
      def link_to_mentioned_user(login)
        user = context[:mentionable_users].find { |u| u.email == login }
        return unless user

        result[:mentioned_usernames] |= [login]

        context[:view_context].avatar_image(user, size: 20, include_name: true, class: 'gravatar-inline')
      end
    end
  end
end
