require 'rails_helper'

describe 'QA Issues' do
  before do
    login_to_project_as_user
  end

  let(:commentable) do
    create(:issue, node: current_project.issue_library, state: :ready_for_review)
  end

  include_examples 'inline threads'
end
