class AddStateToEvidence < ActiveRecord::Migration[8.0]
  def up
    add_column :evidence, :state, :integer, default: 0, null: false

    Evidence.update_all(state: :published)
  end

  def down
    remove_column :evidence, :state
  end
end
