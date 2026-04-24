require 'rails_helper'

describe 'Tasks Summary', js: true do
  before do
    login_to_project_as_user

    board = create(:board, project: current_project, node: current_project.methodology_library)
    list = create(:list, board: board)
    @card = create(:card, list: list)
  end

  it 'renders the My Cards widget when cards are assigned to the user' do
    @card.assignees = [current_user]
    @card.save

    visit project_path(current_project)

    expect(page).to have_content('My Cards')
    expect(page).to have_selector('ul.tasks')
  end
end
