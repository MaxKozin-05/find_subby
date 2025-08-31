class AddRoleAndPlanToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :integer, null: false, default: 0
    add_column :users, :plan, :integer, null: false, default: 0
    add_index :users, :role
  end
end
