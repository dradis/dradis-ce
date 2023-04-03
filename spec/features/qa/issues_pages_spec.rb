require 'rails_helper'

describe 'Issues pages' do
  it 'should require authenticated users' do
    visit project_issues_path(create(:project))
    expect(current_path).to eq(login_path)
    expect(page).to have_content('Access denied.')
  end

  context 'as authenticated user' do
    before { login_to_project_as_user }

    let!(:records) do
      create_list(:issue, 10, state: :ready_for_review, node: current_project.issue_library)
    end

    include_examples 'qa pages', :issue
  end
end
