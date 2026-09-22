# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AvatarHelper do
  let(:user) { User.new(name: 'Test User', email: 'Test@example.com') }

  describe '#avatar_image' do
    it 'renders the local default and loads Gravatar through Stimulus without a referrer' do
      image = Nokogiri::HTML.fragment(helper.avatar_image(user, size: 24)).at_css('img')

      expect(image['src']).to eq(helper.image_path(AvatarHelper::DEFAULT_PROFILE_IMAGE))
      expect(image['data-controller']).to eq('gravatar')
      expect(image['data-gravatar-url']).to eq(helper.avatar_url(user, size: 24))
      expect(image['referrerpolicy']).to eq('no-referrer')
      expect(image['width']).to eq('24')
      expect(image['height']).to eq('24')
      expect(image['onerror']).to be_nil
      expect(image['data-fallback-image']).to be_nil
    end

    it 'preserves the optional name and custom fallback' do
      fragment = Nokogiri::HTML.fragment(helper.avatar_image(user, fallback_image: '/custom.png', include_name: true))

      expect(fragment.at_css('img')['src']).to eq('/custom.png')
      expect(fragment.text).to eq(" #{user.name}")
    end

    it 'renders an uploaded Pro avatar immediately' do
      pro_user = double(:user, avatar: '/uploads/avatar.png', email: user.email, name: user.name, role?: false)
      image = Nokogiri::HTML.fragment(helper.avatar_image(pro_user)).at_css('img')

      expect(image['src']).to eq('/uploads/avatar.png')
      expect(image['data-gravatar-url']).to eq(image['src'])
    end

    it 'renders the default when a Pro user has no uploaded avatar' do
      pro_user = double(:user, avatar: nil, email: user.email, name: user.name, role?: false)
      image = Nokogiri::HTML.fragment(helper.avatar_image(pro_user)).at_css('img')

      expect(image['src']).to eq(helper.image_path(AvatarHelper::DEFAULT_PROFILE_IMAGE))
      expect(image['data-gravatar-url']).to start_with('https://secure.gravatar.com/avatar/')
    end

    it 'renders a local image for a removed user' do
      image = Nokogiri::HTML.fragment(helper.avatar_image(nil)).at_css('img')

      expect(image['src']).to eq(helper.image_path(AvatarHelper::DEFAULT_PROFILE_IMAGE))
      expect(image['data-gravatar-url']).to eq(image['src'])
    end
  end

  describe '#avatar_url' do
    it 'uses the public GitHub default without disclosing the instance URL' do
      expect(helper).not_to receive(:image_url)
      url = URI.parse(helper.avatar_url(user, size: 24))

      expect(url.host).to eq('secure.gravatar.com')
      expect(url.path).to eq("/avatar/#{Digest::MD5.hexdigest('test@example.com')}")
      expect(URI.decode_www_form(url.query).to_h).to eq(
        'd' => AvatarHelper::GRAVATAR_DEFAULT_IMAGE_URL,
        'r' => 'PG',
        's' => '48'
      )
    end

    it 'uses the local default for a username without an email address' do
      user.email = 'author'

      expect(helper.avatar_url(user)).to eq(helper.image_path(AvatarHelper::DEFAULT_PROFILE_IMAGE))
    end
  end
end
