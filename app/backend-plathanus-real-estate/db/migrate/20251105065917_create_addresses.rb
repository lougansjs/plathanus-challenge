class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.references :property, null: false, foreign_key: true, index: { unique: true }
      t.string :street
      t.string :neighborhood
      t.string :city
      t.string :state
      t.string :country, default: 'Brasil'
      t.string :zipcode
      t.decimal :latitude,  precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.timestamps
    end

    add_index :addresses, %i[city state]
  end
end
