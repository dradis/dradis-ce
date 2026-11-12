require 'rails_helper'

describe CommentsHelper do
  it 'resolves mentions separately for each comment rendered by the same helper' do
    first_user = create(:user)
    second_user = create(:user)
    first = build(:comment, content: "Thanks @#{first_user.email}")
    second = build(:comment, content: "Thanks @#{second_user.email}")
    expect(Comment).to receive(:mentionable_users).with(first.commentable).once.and_return([first_user])
    expect(Comment).to receive(:mentionable_users).with(second.commentable).once.and_return([second_user])
    allow(helper).to receive(:avatar_image) { |user, _options| "<span>#{user.name}</span>" }

    expect(helper.comment_formatter(first)).to include("<span>#{first_user.name}</span>")
    expect(helper.comment_formatter(second)).to include("<span>#{second_user.name}</span>")
    expect(helper.comment_formatter(first)).to include("<span>#{first_user.name}</span>")
  end
end
