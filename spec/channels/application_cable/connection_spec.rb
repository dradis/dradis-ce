require 'rails_helper'

describe ApplicationCable::Connection, type: :channel do
  let(:user) { create(:user) }
  let(:env) { instance_double('env') }

  before do
    allow_any_instance_of(ApplicationCable::Connection).to receive(:env).and_return(env)
    allow(env).to receive(:[]).with('warden').and_return(warden)
  end

  context 'with authenticated user' do
    let(:warden) { instance_double('warden', user: user) }

    it 'connects with params' do
      connect '/cable'
      expect(connection.current_user.id).to eq user.id
    end
  end

  context 'with un authenticated user' do
    let(:warden) { instance_double('warden', user: nil) }

    it 'rejects connection without params' do
      expect { connect '/cable' }.to have_rejected_connection
    end
  end
end
