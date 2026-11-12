require 'rails_helper'

describe 'Comment mentions', js: true do
  before do
    login_to_project_as_user
    allow_any_instance_of(Project).to receive(:reviewers).and_return(User.all)
  end

  let(:issue) { create(:issue, node: current_project.issue_library, state: :ready_for_review) }

  def select_mention(editor)
    editor.send_keys('@', @logged_in_as.email)
    find('.tribute-container li', text: @logged_in_as.email).click
    expect(editor.value).to include("@#{@logged_in_as.email}")
  end

  it 'initializes autocomplete in fetched and edited comments without layout metadata' do
    visit project_issue_path(current_project, issue)

    expect(page).not_to have_css('meta[name=mentionable-users]', visible: :all)
    select_mention(find('[data-behavior~=add-comment] [data-controller~=mentions][data-tribute]'))
    click_button 'Add comment'
    expect(page).to have_css('[data-behavior~=comment-list] .gravatar-inline', text: @logged_in_as.name)

    comment = Comment.last
    find("#comment_#{comment.id}").hover
    within("#comment_#{comment.id}") { click_link 'Edit' }
    editor = find("#comment_#{comment.id} [data-controller~=mentions][data-tribute]")
    editor.set('Updated ')
    select_mention(editor)
    click_button 'Update comment'
    expect(page).to have_css("#comment_#{comment.id} .gravatar-inline", text: @logged_in_as.name)
    expect(page).to have_text('Updated')
  end

  it 'initializes autocomplete in new threads and replaced reply forms' do
    visit project_qa_issue_path(current_project, issue)
    expect(page).to have_css('[data-behavior~=inline-threads-container]')
    page.execute_script(<<~JS)
      const container = document.querySelector('[data-behavior~=inline-threads-container]');
      const selector = $(container).data('inlineThreadSelector');
      selector.coordinator.showNewThreadForm(selector.buildAnchor('Apache bugs'));
    JS

    select_mention(find('[data-behavior~=inline-thread-content] [data-controller~=mentions][data-tribute]'))
    click_button 'Create Thread'
    expect(page).to have_css('[data-behavior~=inline-thread-content] .gravatar-inline', count: 1)

    2.times do |index|
      select_mention(find('[data-behavior~=inline-thread-content] [data-controller~=mentions][data-tribute]'))
      click_button 'Reply'
      expect(page).to have_css('[data-behavior~=inline-thread-content] .gravatar-inline', count: index + 2)
    end

    expect(page).to have_css('.tribute-container', count: 1, visible: :all)
    page.refresh
    expect(page).to have_css('[data-thread-id]')
  end
end
