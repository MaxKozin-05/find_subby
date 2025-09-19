# db/migrate/xxx_create_notifications.rb
class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :notifiable, polymorphic: true, null: false
      t.string :title, null: false
      t.text :message
      t.boolean :read, default: false, null: false
      t.string :notification_type
      t.timestamps
    end

    add_index :notifications, [:user_id, :read]
    add_index :notifications, [:notifiable_type, :notifiable_id]
    add_index :notifications, :created_at
  end
end
