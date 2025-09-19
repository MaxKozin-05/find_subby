# db/migrate/xxx_create_jobs.rb
class CreateJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :jobs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :client_name, null: false
      t.string :client_email, null: false
      t.string :client_phone
      t.string :title, null: false
      t.text :description
      t.integer :status, default: 0, null: false
      t.decimal :estimated_budget, precision: 10, scale: 2
      t.date :preferred_start_date
      t.text :location
      t.timestamps
    end
  end
end
