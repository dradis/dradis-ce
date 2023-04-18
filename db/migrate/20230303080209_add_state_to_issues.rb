class AddStateToIssues < ActiveRecord::Migration[6.1]
  def up
    add_column :notes, :state, :integer, default: 0, null: false

    Issue.transaction do
      Issue.update_all(state: :published)
    end
  end

  def down
    remove_column :notes, :state
  end
end
