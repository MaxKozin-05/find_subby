# db/migrate/xxxx_create_profiles.rb
class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string  :handle, null: false
      t.string  :business_name, null: false
      t.string  :trade_type
      t.text    :service_areas, array: true, default: []
      t.text    :about
      t.jsonb   :companies_json, default: []
      t.timestamps
    end
    add_index :profiles, :handle, unique: true
    add_index :profiles, :companies_json, using: :gin
  end
end
