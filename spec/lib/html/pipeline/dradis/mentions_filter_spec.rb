require 'rails_helper'

describe HTML::Pipeline::Dradis::MentionsFilter do
  it 'leaves mentions as plain text when no mentionable users are given' do
    source = '<p>Thanks @someone@example.com</p>'
    doc = described_class.call(source, mentionable_users: nil, username_pattern: Comment::MENTION_PATTERN)

    expect(doc.to_s).to eq(source)
  end
end
