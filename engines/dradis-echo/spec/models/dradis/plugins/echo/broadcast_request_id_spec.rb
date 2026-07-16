require 'rails_helper'

Dir[Dradis::Plugins::Echo::Engine.root.join('spec/factories/*.rb')].sort.each { |f| require f }

# SEC-506 Bug 1/2 regression: turbo-rails 2.0.4 broadcastable.rb:503 reverse_merges
# `request_id: Turbo.current_request_id` into every broadcast partial's locals. In a
# real request the RequestId middleware sets a non-nil id, so it reaches the partial;
# in a job / rack_test it's nil and .compact drops it. Both Echo broadcast-target
# partials use strict locals, so unless they tolerate `request_id`, the broadcasts
# that fire *inside SessionsController#create* (Message#broadcast_created and, via
# request_reply!, Session#broadcast_composer_state) raise StrictLocalsError → 500.
#
# A plain request spec can't catch this (nil request_id), which is why it slipped
# through. We force a non-nil id with Turbo.with_request_id so the render exercises
# the exact failing path.
describe 'Echo broadcasts under a non-nil Turbo request id' do
  let(:user) { create(:user) }
  let(:agent) { create(:agent) }
  let(:session) { create(:echo_session, agent: agent) }

  around do |example|
    Turbo.with_request_id('sec506-req-id') { example.run }
  end

  it 'renders _message via Message#broadcast_created without StrictLocalsError' do
    message = create(:echo_message, session: session, role: :user, user: user)

    expect { message.send(:broadcast_created) }.not_to raise_error
  end

  it 'renders _message for an assistant turn too' do
    message = create(:assistant_message, session: session)

    expect { message.send(:broadcast_created) }.not_to raise_error
  end

  it 'renders _composer_state via Session#broadcast_composer_state without StrictLocalsError' do
    expect { session.broadcast_composer_state }.not_to raise_error
  end
end
