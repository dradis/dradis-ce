class AddStateToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :notes, :state, :integer, default: 0

    # Mark all existing issues as published
    Issue.update_all(state: Issue.states[:published])
  end
end
