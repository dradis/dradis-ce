require 'rails_helper'

Dir[Dradis::Plugins::Echo::Engine.root.join('spec/factories/*.rb')].sort.each { |f| require f }

# End-to-end coverage of the Echo session flow through the real views, controllers
# and models: start a session from a saved prompt, persist the first exchange, and
# prove a follow-up retains the prior transcript. The provider is stubbed so the
# reply is deterministic, and ReplyJob runs inline (perform_enqueued_jobs) so the
# assistant turn is persisted within the request — no ActionCable needed (the test
# cable adapter never delivers to a browser anyway).
describe 'Echo sessions' do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }

  before do
    login_as_user(user)
    @project = Project.new

    # Capture the context handed to the provider each turn so we can assert the
    # follow-up carried the full history forward.
    @contexts = []
    allow_any_instance_of(Dradis::Plugins::Echo::Provider::Ollama)
      .to receive(:generate) do |_provider, messages:, model: nil, &block|
        @contexts << messages
        block.call("Roslin reply #{@contexts.size}")
      end
  end

  let!(:roslin) do
    Dradis::Plugins::Echo::Agents::Roslin.provision!.tap { |agent| agent.update!(enabled: true) }
  end

  let(:issue) { create(:issue, node: @project.issue_library, text: "#[Title]#\nSQLi") }

  let!(:prompt) do
    user.prompts.create!(
      title: 'Summarise the finding',
      prompt: 'Summarise {{ issue.title }}',
      scope: 'issue',
      visibility: :user
    )
  end

  # Generation is started by the session Stimulus controller once subscribed, not
  # by sessions#create. rack_test has no JS, so drive that reply-trigger POST
  # explicitly and run the job inline.
  def start_session
    visit echo.preview_project_interaction_path(@project.id, prompt.id, type: 'issue', record: issue.id)
    click_button 'Start with this prompt'

    session = Dradis::Plugins::Echo::Session.last
    perform_enqueued_jobs { page.driver.post(echo.project_session_reply_path(@project.id, session)) }
    session
  end

  it 'starts a session from a prompt and persists the streamed first exchange' do
    session = start_session

    expect(session.title).to eq('Summarise the finding')
    expect(session.user).to eq(user)
    expect(session.record).to eq(issue)

    expect(session.messages.order(:id).pluck(:role, :content)).to eq([
      %w[user Summarise\ SQLi],
      %w[assistant Roslin\ reply\ 1]
    ])
    expect(session.reload).to be_idle

    # The reply is generated after create renders show, so it lands on reload.
    visit echo.project_session_path(@project.id, session, type: 'issue', record: issue.id)
    expect(page).to have_content('Roslin reply 1')
  end

  it 'retains the conversation context on a follow-up message after reload' do
    session = start_session

    # Reload the conversation: the first reply has finished, so the transcript
    # survives (acceptance: survives reload) and the composer re-enables.
    visit echo.project_session_path(@project.id, session, type: 'issue', record: issue.id)
    expect(page).to have_content('Roslin reply 1')

    fill_in 'content', with: 'What is the impact?'
    perform_enqueued_jobs { click_button 'Send' }

    expect(session.messages.reload.order(:id).pluck(:role, :content)).to eq([
      %w[user Summarise\ SQLi],
      %w[assistant Roslin\ reply\ 1],
      ['user', 'What is the impact?'],
      %w[assistant Roslin\ reply\ 2]
    ])

    # The provider's second turn saw the whole prior transcript — context retained.
    expect(@contexts.last.map { |message| message[:content] }).to eq(
      ['Summarise SQLi', 'Roslin reply 1', 'What is the impact?']
    )
    expect(session.reload).to be_idle
  end
end
