require 'rails_helper'

Dir[Dradis::Plugins::Echo::Engine.root.join('spec/factories/*.rb')].sort.each { |f| require f }

# SEC-506 live-browser acceptance for the Echo Sessions conversation UI. These are
# the flows the rack_test request specs structurally cannot exercise (the documented
# live-JS/Turbo gap): the Bootstrap tab-show that triggers the native lazy frame, and
# the Turbo-frame back-navigation between sessions#show and interactions#index.
describe 'Echo Sessions conversation UI', js: true do
  before { login_to_project_as_user }

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

  # Bug 3: the frame-mechanism swap (data-behavior=fetch -> native lazy turbo-frame).
  it 'lazy-loads the conversation list when the Echo tab is shown and returns to it via the "+ New" link' do
    session = create(:echo_session, agent: roslin, record: issue, title: 'Earlier conversation')
    create(:echo_message, session: session, role: :user, content: 'my earlier question', user: @logged_in_as)

    visit project_issue_path(current_project, issue)

    # The Echo tab-pane is hidden until the Bootstrap tab is shown; showing it must
    # trigger the native <turbo-frame loading="lazy" src=...> to fetch interactions#index.
    click_link 'Echo'
    expect(page).to have_css("turbo-frame#echo_issue_#{issue.id}")
    expect(page).to have_content('Earlier conversation') # lazy frame loaded on tab-show

    # Into the session (sessions#show renders into the same native frame).
    find('.echo-session-item', text: 'Earlier conversation').click
    expect(page).to have_content('my earlier question')

    # Back to the list: Turbo navigates the frame to interactions#index. Before the
    # fix this reported "Content missing" (index answered frameless).
    find('.echo-new-conversation-link').click
    expect(page).to have_content('Earlier conversation')
    expect(page).to have_no_content('Content missing')
  end

  # Bug 1: sessions#create -> render :show must be 200, not a StrictLocalsError 500.
  it 'starts a conversation from a saved prompt without a StrictLocalsError' do
    visit project_issue_path(current_project, issue)
    click_link 'Echo'

    # The prompt-selector stimulus controller auto-loads the selected prompt's preview
    # form (the "Start with this prompt" submit) into the echo-prompt-preview frame.
    expect(page).to have_button('Start with this prompt')
    click_button 'Start with this prompt'

    # The create response renders sessions#show into the echo frame: the first user
    # message (the prompt body) appears and no error page / strict-locals crash.
    expect(page).to have_content('Summarise the issue')
    expect(page).to have_no_content('unknown local')
    expect(page).to have_css('.echo-conversation')
  end
end
