require 'rails_helper'

Dir[Dradis::Plugins::Echo::Engine.root.join('spec/factories/*.rb')].sort.each { |f| require f }

# SEC-509 (SEC-469 Bug 2): prove the assistant reply *broadcasts and renders live*
# on initial session creation, over the real ActionCable path — not the inline
# request-time render the rack_test session specs rely on.
#
# The rack_test session specs run ReplyJob synchronously inside the request
# (perform_enqueued_jobs) and read the persisted reply out of the re-rendered
# HTML, so they never exercise ActionCable at all. This spec closes that gap:
#
#   * a *real Redis-backed* cable adapter (not the test/async adapter) carries
#     the broadcast, driven by a real headless-Firefox browser,
#   * ReplyJob runs out-of-band (the client POSTs to replies#create from the
#     Stimulus `connect`, i.e. after subscribing — the SEC-506 Bug 4 ordering),
#   * a stubbed provider streams two canned chunks, gated by a Queue so we can
#     assert the *first* chunk has rendered while the message is still streaming,
#     then release the second and assert the completed reply — proving live,
#     incremental turbo-stream render rather than a single post-hoc paint.
#
# The assistant text is never in the create/#show HTML (create no longer starts
# generation), so its appearance in the DOM can only have arrived over the cable.
#
# Determinism: the browser subscribes to [session, :messages] on page load, well
# before the Stimulus `connect` POSTs to trigger the reply; the only race is that
# an *eager* in-request broadcast could beat the subscribe handshake. ReplyJob
# runs inline in the request thread, so we hold its first broadcast back a beat
# (Session#to_provider_messages settle, before the streaming message is created)
# to let the subscription settle. Once a broadcast lands on an established
# subscriber it renders even while that request thread is parked (which is how
# the first chunk is asserted before the second is released). Cable auth is
# stubbed to need no DB: under transactional fixtures the single shared
# connection is held by the inline job, so a DB-touching subscribe would deadlock.
describe 'Echo initial-creation streaming', js: true do
  # Long enough for the (DB-free) subscribe handshake to settle before ReplyJob's
  # first broadcast; the browser has been subscribing since the show render.
  SUBSCRIBE_SETTLE = 2.0

  # Held between the two provider chunks so the first renders live before the
  # second is emitted.
  let(:second_chunk_gate) { Queue.new }

  before do
    login_to_project_as_user

    # ActionCable authenticates over Warden (env['warden'].user), which the
    # controller-level login stub doesn't populate. Identify the connection and
    # authorize the channel directly so the browser's subscription is accepted
    # and broadcasts land — the streaming render, not auth, is under test.
    # Both the connection (find_verified_user) and the channel authorization
    # (session_from_stream_name -> GlobalID DB locate, authorized? -> Ability)
    # are stubbed so the subscription needs no database. Under transactional
    # fixtures the DB is a single shared connection; letting the cable subscribe
    # touch it would deadlock against the in-request inline ReplyJob that holds
    # that connection. Streaming render — not auth — is what's under test.
    allow_any_instance_of(ApplicationCable::Connection)
      .to receive(:find_verified_user).and_return(@logged_in_as)
    allow_any_instance_of(Dradis::Plugins::Echo::SessionsChannel)
      .to receive(:session_from_stream_name).and_return(true)
    allow_any_instance_of(Dradis::Plugins::Echo::SessionsChannel)
      .to receive(:authorized?).and_return(true)

    use_redis_cable!
    ActiveJob::Base.queue_adapter = :inline

    # Hold ReplyJob a beat before it creates+broadcasts the streaming message so
    # the browser's subscription is live when the first broadcast lands.
    allow_any_instance_of(Dradis::Plugins::Echo::Session)
      .to receive(:to_provider_messages).and_wrap_original do |original, *args|
        sleep SUBSCRIBE_SETTLE
        original.call(*args)
      end

    # Canned two-chunk stream; blocks on the gate between chunks.
    allow_any_instance_of(Dradis::Plugins::Echo::Provider::Ollama)
      .to receive(:generate) do |_provider, messages:, model: nil, &block|
        block.call('Streaming token one ')
        second_chunk_gate.pop
        block.call('and token two.')
      end
  end

  after do
    # Never leave the inline ReplyJob (running in the server thread) parked.
    second_chunk_gate << :go until second_chunk_gate.empty?
    ActiveJob::Base.queue_adapter = :test
    restore_cable!
  end

  let!(:roslin) do
    Dradis::Plugins::Echo::Agents::Roslin.provision!.tap { |a| a.update!(enabled: true) }
  end

  let(:issue) { create(:issue, node: current_project.issue_library, text: "#[Title]#\nSQLi") }

  let!(:prompt) do
    @logged_in_as.prompts.create!(
      title: 'Summarise the finding',
      prompt: 'Summarise the issue',
      scope: 'issue',
      visibility: :user
    )
  end

  it 'streams and renders the assistant reply live on initial creation' do
    visit project_issue_path(current_project, issue)
    click_link 'Echo'

    expect(page).to have_button('Start with this prompt')
    click_button 'Start with this prompt'

    # Session created, first user message rendered, real cable is up (no Redis
    # error alert from SessionsController#check_turbo_config).
    expect(page).to have_content('Summarise the issue')
    expect(page).to have_no_content('error contacting Redis')

    # The first chunk streams in over the cable while the message is still
    # streaming. This text was never in the create/#show HTML — it can only have
    # arrived via the ActionCable turbo-stream broadcast.
    expect(page).to have_css('.echo-message-assistant.echo-message-streaming', wait: 20)
    expect(page).to have_content('Streaming token one', wait: 20)
    expect(page).to have_content('Roslin is responding')
    expect(page).to have_no_content('and token two')

    # Release the rest: the second chunk appends and the message completes.
    second_chunk_gate << :go

    expect(page).to have_content('Streaming token one and token two.', wait: 20)
    expect(page).to have_no_css('.echo-message-streaming', wait: 20)

    # The reply is persisted as a completed assistant message.
    session = Dradis::Plugins::Echo::Session.for_record(issue).order(:id).last
    assistant = session.messages.where(role: :assistant).last
    expect(assistant.content).to eq('Streaming token one and token two.')
    expect(assistant).to be_complete
  end

  private

  # Point the process-wide ActionCable server at the real Redis pub/sub adapter
  # for the duration of the example, re-initialising the memoised adapter so the
  # browser subscription and ReplyJob's broadcasts both traverse Redis.
  def use_redis_cable!
    server = ActionCable.server
    @original_cable = server.config.cable
    server.config.cable = ActiveSupport::HashWithIndifferentAccess.new(
      'adapter' => 'redis',
      'url' => ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
      'channel_prefix' => 'echo_sec509_test'
    )
    server.instance_variable_set(:@pubsub, nil)
  end

  def restore_cable!
    server = ActionCable.server
    server.config.cable = @original_cable
    server.instance_variable_set(:@pubsub, nil)
  end
end
