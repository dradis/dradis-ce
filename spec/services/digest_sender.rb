# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigestSender do

  describe '.send_digests' do
    it 'sends the digest' do
    end
  end

  describe '.send_instants' do
    it 'sends the instants' do
    end
  end

  describe '.digest_users' do
    context 'instant' do
      user = create(:user)
      user.preferences.digest_frequency = 'instant'
      user.save

      expect(DigestSender.digest_users(type: 'instant')).to include(user)
    end

    context 'daily' do
      user = create(:user)
      user.preferences.digest_frequency = 'daily'
      user.save

      DigestSender.digest_users(type: 'daily').to include(user)
    end
  end

end
