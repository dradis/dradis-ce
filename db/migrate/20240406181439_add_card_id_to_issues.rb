class AddCardIdToIssues < ActiveRecord::Migration[7.0]
  def up
    add_reference :notes, :card, foreign_key: true
  end

  def down
    remove_reference :notes, :card
  end
end
