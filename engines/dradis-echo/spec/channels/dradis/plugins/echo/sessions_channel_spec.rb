require 'rails_helper'

Dir[Dradis::Plugins::Echo::Engine.root.join('spec/factories/*.rb')].sort.each { |f| require f }

describe Dradis::Plugins::Echo::SessionsChannel, type: :channel do
  let(:user) { create(:user) }
  let(:agent) { create(:agent) }
  let(:session) { create(:echo_session, agent: agent) }

  let(:signed_name) { Turbo::StreamsChannel.signed_stream_name([session, :messages]) }
  let(:stream_name) { Turbo::StreamsChannel.verified_stream_name(signed_name) }

  before { stub_connection(current_user: user) }

  it 'accepts the subscription and streams the transcript for an authorized user' do
    subscribe(signed_stream_name: signed_name)

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from(stream_name)
  end

  it 'rejects a user whose :use on the record project is denied' do
    allow_any_instance_of(Ability).to receive(:can?).and_return(false)

    subscribe(signed_stream_name: signed_name)

    expect(subscription).to be_rejected
  end

  # Re-authorizes at subscribe time: the same signed name is accepted while the
  # user may :use the project and rejected once that permission is revoked.
  it 'flips between accept and reject as authorization changes' do
    subscribe(signed_stream_name: signed_name)
    expect(subscription).to be_confirmed

    allow_any_instance_of(Ability).to receive(:can?).and_return(false)

    subscribe(signed_stream_name: signed_name)
    expect(subscription).to be_rejected
  end

  it 'rejects a tampered stream name that fails verification' do
    subscribe(signed_stream_name: 'not-a-valid-signed-stream-name')

    expect(subscription).to be_rejected
  end
end
