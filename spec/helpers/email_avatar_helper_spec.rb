# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailAvatars do
  let(:message) { Mail.new }
  let(:user) { User.new(email: 'author@example.com') }

  before do
    mail_message = message
    helper.define_singleton_method(:attachments) { mail_message.attachments }
  end

  it 'embeds the default image without browser-only behavior' do
    image = Nokogiri::HTML.fragment(helper.avatar_image(user)).at_css('img')

    expect(image['src']).to start_with('cid:')
    expect(image['data-controller']).to be_nil
    expect(image['data-gravatar-url']).to be_nil
    expect(image['onerror']).to be_nil
    expect(message.attachments['avatar.png'].decoded).to eq(File.binread(Rails.root.join('app/assets/images/avatar.png')))
  end

  it 'reuses the attachment for repeated and removed users' do
    helper.avatar_image(user)
    helper.avatar_image(nil)

    expect(message.attachments.size).to eq(1)
  end

  it 'embeds uploaded avatars when available' do
    path = Rails.root.join('spec/fixtures/files/rails.png')
    stub_const('Avatar', double(file_path: path))
    user.define_singleton_method(:avatar) { '/avatars/upload.png' }

    image = Nokogiri::HTML.fragment(helper.avatar_image(user)).at_css('img')

    expect(image['src']).to eq(message.attachments['rails.png'].url)
    expect(message.attachments['rails.png'].decoded).to eq(File.binread(path))
  end
end
