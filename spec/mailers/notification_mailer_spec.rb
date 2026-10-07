# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationMailer do
  it 'embeds avatars in the header and notification rows' do
    user = create(:user)
    notification = create(:notification, recipient: user, notifiable: create(:comment))
    mail = described_class.with(
      user: user,
      notifications: { 'Comments' => { 'comment' => [notification] } },
      type: :instant
    ).digest
    html = Nokogiri::HTML(mail.html_part.body.decoded)
    avatars = html.css('.gravatar img')

    expect(avatars.size).to eq(2)
    expect(avatars.map { |image| image['src'] }).to all(start_with('cid:'))
    expect(html.css('[data-controller], [data-gravatar-url], [onerror]')).to be_empty
    expect(mail.attachments['avatar.png']).to be_present
  end
end
