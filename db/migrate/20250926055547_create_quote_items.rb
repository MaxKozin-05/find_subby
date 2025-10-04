class CreateQuoteItems < ActiveRecord::Migration[7.1]
  def change
    create_table :quote_items do |t|
      t.references :quote, null: false, foreign_key: true
      t.string :description, null: false
      t.decimal :quantity, precision: 10, scale: 2, default: 1.0, null: false
      t.string :unit, default: 'each'
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.integer :category, null: false # labour: 0, materials: 1
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :quote_items, :category
    add_index :quote_items, :position
  end
end
