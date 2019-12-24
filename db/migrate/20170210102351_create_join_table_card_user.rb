class CreateJoinTableCardUser < ActiveRecord::Migration[5.1]
  def change
    create_join_table :cards, :users do |t|
      t.index [:card_id, :user_id]
      t.index [:user_id, :card_id]
    end
  end
end
