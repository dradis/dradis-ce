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

  # Build an anchor by simulating what getSelection().toString() returns.
  # We read innerText from the DOM to discover the actual separator between
  # block elements (e.g. \n\n between h5 and p), then extract the substring
  # that corresponds to the described selection.
  def build_anchor(selected_text)
    page.evaluate_script(<<~JS)
      (function() {
        var container = document.querySelector('[data-behavior~=inline-threads-container]');
        var selector = $(container).data('inlineThreadSelector');
        return selector.buildAnchor(#{selected_text.to_json});
      })()
    JS
  end

  def rendered_text
    @rendered_text ||= page.evaluate_script(<<~JS)
      (function() {
        var container = document.querySelector('[data-behavior~=inline-threads-container]');
        var selector = $(container).data('inlineThreadSelector');
        return selector.renderedText;
      })()
    JS
  end

  # Extract a substring from the rendered text between two landmarks.
  # This ensures test selections match innerText exactly.
  def selection_between(from_text, to_text)
    text = rendered_text
    start_idx = text.index(from_text)
    end_idx = text.index(to_text)
    text[start_idx..(end_idx + to_text.length - 1)]
  end

  it 'handles selection of multi-line content (no fields)' do
    selected = selection_between(
      'The application is vulnerable',
      'An attacker can extract data from the database.'
    )
    anchor = build_anchor(selected)

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
    expect(anchor['field_name']).to eq('Description')
  end

  it 'handles selection of a field name + 1 line of content' do
    selected = selection_between(
      'Description',
      'The application is vulnerable to SQL injection.'
    )
    anchor = build_anchor(selected)

    expect(anchor).to be_present
    expect(anchor['exact']).to include('Description')
    expect(anchor['exact']).to include('The application is vulnerable')
    expect(anchor['field_name']).to eq('Description')
  end

  it 'handles selection of a field name + 2 lines of content' do
    selected = selection_between(
      'Description',
      'An attacker can extract data from the database.'
    )
    anchor = build_anchor(selected)

    expect(anchor).to be_present
    expect(anchor['exact']).to include('Description')
    expect(anchor['exact']).to include('The application is vulnerable')
    expect(anchor['exact']).to include('An attacker can extract data')
    expect(anchor['field_name']).to eq('Description')
  end

  it 'handles selection spanning across 2 fields' do
    selected = selection_between(
      'An attacker can extract data from the database.',
      'Use parameterized queries.'
    )
    anchor = build_anchor(selected)

    expect(anchor).to be_present
    expect(anchor['exact']).to include('An attacker can extract data')
    expect(anchor['exact']).to include('Recommendation')
    expect(anchor['exact']).to include('Use parameterized queries')
    expect(anchor['field_name']).to eq('Description')
  end
end
