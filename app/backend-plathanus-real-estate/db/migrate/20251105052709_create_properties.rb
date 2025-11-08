class CreateProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :properties do |t|
      t.string :name,           null: false
      t.references :category,    null: false, foreign_key: true
      t.string  :status,         null: false
      t.integer :rooms,          null: false
      t.integer :bathrooms,      null: false
      t.integer :area,           null: false
      t.integer :parking_slots
      t.boolean :furnished,      null: false, default: false
      t.string  :contract_type,  null: false

      # Campos novos (sem validação/obrigatoriedade no DB)
      t.string  :code
      t.decimal :promotional_price, precision: 10, scale: 2
      t.date    :available_from

      # Estruturas compostas
      t.jsonb   :rooms_list, default: [], null: false
      t.string  :apartment_amenities, array: true, default: [], null: false
      t.string  :building_characteristics, array: true, default: [], null: false

      # Descrição e preço
      t.text    :description
      t.decimal :price, precision: 10, scale: 2
      t.timestamps
    end
    add_index :properties, :status
    add_index :properties, :code, unique: false
  end
end
