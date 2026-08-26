require 'rails_helper'
require File.expand_path('../../../../factories/providers', __dir__)
require File.expand_path('../../../../factories/agents', __dir__)
require File.expand_path('../../../../factories/sessions', __dir__)
require File.expand_path('../../../../factories/messages', __dir__)

describe Dradis::Plugins::Echo::Message do
  describe 'relationships' do
    it { should belong_to(:session) }
    it { should belong_to(:parent).class_name('Dradis::Plugins::Echo::Message').optional }
    it { should belong_to(:user).optional }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(%i[user assistant]) }
    it { should define_enum_for(:status).with_values(%i[complete streaming failed]) }

    it 'defaults status to complete' do
      expect(build(:echo_message).status).to eq('complete')
    end
  end

  describe 'validations' do
    it 'requires content when complete' do
      message = build(:echo_message, status: :complete, content: nil)
      expect(message).not_to be_valid
      expect(message.errors[:content]).to be_present
    end

    it 'allows blank content while streaming' do
      message = build(:assistant_message, status: :streaming, content: nil)
      expect(message).to be_valid
    end

    it 'rejects a user on an assistant message' do
      message = build(:assistant_message, user: create(:user))
      expect(message).not_to be_valid
      expect(message.errors[:user_id]).to be_present
    end
  end

  describe 'user messages' do
    it 'are forced to complete' do
      message = create(:echo_message, role: :user, status: :streaming)
      expect(message.status).to eq('complete')
    end
  end

  describe 'role derivation' do
    it 'derives the user role from the author when none is given' do
      message = build(:echo_message, role: nil)
      message.valid?
      expect(message.role).to eq('user')
    end

    it 'leaves an explicit assistant role untouched' do
      message = build(:assistant_message)
      message.valid?
      expect(message.role).to eq('assistant')
    end
  end

  describe 'metadata' do
    it 'is stored as JSON' do
      message = create(:echo_message, metadata: { 'model' => 'qwen2.5:14b' })
      expect(message.reload.metadata).to eq('model' => 'qwen2.5:14b')
    end
  end

  # Acceptance: the partial must render from `render partial:` with only a
  # message: local — no controller context.
  describe 'the _message partial' do
    def render_message(message)
      ApplicationController.render(
        partial: 'dradis/plugins/echo/projects/sessions/messages/message',
        locals: { message: message }
      )
    end

    it 'names the agent for assistant messages' do
      message = create(:assistant_message)
      expect(render_message(message)).to include(message.session.agent.name)
    end

    it 'names the author for user messages' do
      user = create(:user)
      message = create(:echo_message, user: user)
      expect(render_message(message)).to include(user.name)
    end

    it "falls back to 'Deleted user' when the author is gone" do
      message = create(:echo_message, user: create(:user))
      message.update_column(:user_id, nil)
      expect(render_message(message.reload)).to include('Deleted user')
    end

    it 'shows only a generic summary for a failed message, never the stored error' do
      message = create(
        :assistant_message,
        status: :failed,
        content: nil,
        metadata: { 'error' => 'boom: secret-host:443 raw provider body' }
      )

      html = render_message(message.reload)

      expect(html).to include('Send another message to try again')
      expect(html).not_to include('secret-host')
    end
  end
end
