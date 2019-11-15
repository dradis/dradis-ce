# frozen_string_literal: true

module CommentsHelper
  def comment_formatter(comment)
    mentions_formatter(simple_format(h(comment))).html_safe
  end
end
