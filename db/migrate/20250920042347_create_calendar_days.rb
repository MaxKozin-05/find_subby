class CreateCalendarDays < ActiveRecord::Migration[7.1]
  def change
    create_table :calendar_days do |t|
      t.references :user, null: false, foreign_key: true
      t.date :day, null: false
      t.integer :state, default: 0, null: false # available=0, busy=1, booked=2
      t.text :notes # optional notes for the day

      t.timestamps
    end

    add_index :calendar_days, [:user_id, :day], unique: true
    add_index :calendar_days, :day
    add_index :calendar_days, :state
  end
end
