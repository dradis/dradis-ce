require 'rails_helper'

describe 'InlineThreadSelector#buildAnchor', js: true do
  before do
    login_to_project_as_user
    allow_any_instance_of(Project).to receive(:reviewers).and_return(User.all)

    @issue = create(:issue,
      state: :ready_for_review,
      node: current_project.issue_library,
      text: issue_text
    )

    visit project_qa_issue_path(current_project, @issue)

    # Wait for the inline thread selector to initialize
    expect(page).to have_css('[data-behavior~=inline-threads-container]')
  end

  let(:issue_text) do
    [
      '#[Title]#',
      'SQL Injection in Login',
      '',
      '#[Description]#',
      'The application is vulnerable to SQL injection.',
      'An attacker can extract data from the database.',
      '',
      '#[Recommendation]#',
      'Use parameterized queries.',
      'Validate all user input.'
    ].join("\n")
  end

  def build_anchor(selected_text)
    page.evaluate_script(<<~JS)
      (function() {
        var container = document.querySelector('[data-behavior~=inline-threads-container]');
        var selector = $(container).data('inlineThreadSelector');
        return selector.buildAnchor(#{selected_text.to_json});
      })()
    JS
  end

  it 'handles selection of multi-line content (no fields)' do
    anchor = build_anchor("The application is vulnerable to SQL injection.\nAn attacker can extract data from the database.")

    expect(anchor).to be_present
    expect(anchor['exact']).to include('The application is vulnerable')
    expect(anchor['exact']).to include('An attacker can extract data')
    expect(anchor['field_name']).to eq('Description')
    expect(anchor['position']['start']).to be < anchor['position']['end']
  end

  it 'handles selection of a field name only' do
    anchor = build_anchor('Description')

    expect(anchor).to be_present
    expect(anchor['exact']).to eq('Description')
    # "Description" is a heading — findFieldName walks h5 elements
    # and returns the last heading whose offset <= position.
    # Since Description IS the h5, its offset equals the selection position,
    # so findFieldName returns "Description".
    expect(anchor['field_name']).to eq('Description')
  end

  it 'handles selection of a field name + 1 line of content' do
    anchor = build_anchor("Description\nThe application is vulnerable to SQL injection.")

    expect(anchor).to be_present
    expect(anchor['exact']).to include('Description')
    expect(anchor['exact']).to include('The application is vulnerable')
    expect(anchor['field_name']).to eq('Description')
  end

  it 'handles selection of a field name + 2 lines of content' do
    anchor = build_anchor("Description\nThe application is vulnerable to SQL injection.\nAn attacker can extract data from the database.")

    expect(anchor).to be_present
    expect(anchor['exact']).to include('Description')
    expect(anchor['exact']).to include('The application is vulnerable')
    expect(anchor['exact']).to include('An attacker can extract data')
    expect(anchor['field_name']).to eq('Description')
  end

  it 'handles selection spanning across 2 fields' do
    anchor = build_anchor("An attacker can extract data from the database.\nRecommendation\nUse parameterized queries.")

    expect(anchor).to be_present
    expect(anchor['exact']).to include('An attacker can extract data')
    expect(anchor['exact']).to include('Recommendation')
    expect(anchor['exact']).to include('Use parameterized queries')
    expect(anchor['field_name']).to eq('Description')
  end
end
