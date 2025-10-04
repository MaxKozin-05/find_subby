class CreateQuotes < ActiveRecord::Migration[7.1]
  def change
    create_table :quotes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :job, null: true, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :status, default: 0, null: false # draft, sent, accepted, expired
      t.integer :pricing_model, default: 0, null: false # fixed_price, hourly_rate, cost_plus
      t.integer :version, default: 1, null: false
      t.references :parent_quote, null: true, foreign_key: { to_table: :quotes }
      t.boolean :gst_enabled, default: false, null: false
      t.decimal :gst_rate, precision: 5, scale: 4, default: 0.1

      t.timestamps
    end

    add_index :quotes, :status
    add_index :quotes, :version
  end
end
