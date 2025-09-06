class AddSetupCompleteToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :setup_complete, :boolean, default: false, null: false
    add_index :profiles, :setup_complete
  end
end
