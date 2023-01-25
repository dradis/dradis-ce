class CreateAhoyVisitsAndEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :ahoy_visits do |t|
      t.string :visit_token
      t.string :visitor_token
      t.datetime :started_at
    end

    add_index :ahoy_visits, :visit_token, unique: true

    create_table :ahoy_events do |t|
      t.references :visit
      t.string :name
      t.text :properties
      t.datetime :time
    end

    add_index :ahoy_events, [:name, :time]
  end
end
