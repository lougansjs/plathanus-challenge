class CreateCheckConstraintsOnProperties < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      ALTER TABLE properties
      ADD CONSTRAINT chk_properties_status
      CHECK (status IN ('available','unavailable','rented','sold','maintenance','archived'));
    SQL

    execute <<~SQL
      ALTER TABLE properties
      ADD CONSTRAINT chk_properties_contract_type
      CHECK (contract_type IN ('rent','sale','seasonal'));
    SQL
  end

  def down
    execute "ALTER TABLE properties DROP CONSTRAINT IF EXISTS chk_properties_status;"
    execute "ALTER TABLE properties DROP CONSTRAINT IF EXISTS chk_properties_contract_type;"
  end
end
