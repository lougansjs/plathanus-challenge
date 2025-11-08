class AddPerformanceIndexesToPropertiesAndAddresses < ActiveRecord::Migration[8.0]
  def change
    # Índices para colunas filtradas em properties
    add_index :properties, :price, if_not_exists: true unless index_exists?(:properties, :price)
    add_index :properties, :rooms, if_not_exists: true unless index_exists?(:properties, :rooms)
    add_index :properties, :bathrooms, if_not_exists: true unless index_exists?(:properties, :bathrooms)
    add_index :properties, :parking_slots, if_not_exists: true unless index_exists?(:properties, :parking_slots)
    add_index :properties, :furnished, if_not_exists: true unless index_exists?(:properties, :furnished)
    add_index :properties, :created_at, if_not_exists: true unless index_exists?(:properties, :created_at)

    # Índices GIN para arrays (melhor performance em queries com ANY e &&)
    add_index :properties, :apartment_amenities, using: :gin, if_not_exists: true unless index_exists?(:properties, :apartment_amenities)
    add_index :properties, :building_characteristics, using: :gin, if_not_exists: true unless index_exists?(:properties, :building_characteristics)

    # Índices para colunas filtradas em addresses
    add_index :addresses, :city, if_not_exists: true unless index_exists?(:addresses, :city)
    add_index :addresses, :state, if_not_exists: true unless index_exists?(:addresses, :state)
    add_index :addresses, :neighborhood, if_not_exists: true unless index_exists?(:addresses, :neighborhood)

    # Índice composto para busca por cidade e estado
    add_index :addresses, [:city, :state], if_not_exists: true unless index_exists?(:addresses, [:city, :state])
  end
end
