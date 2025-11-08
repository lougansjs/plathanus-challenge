# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_07_062229) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.string "street"
    t.string "neighborhood"
    t.string "city"
    t.string "state"
    t.string "country", default: "Brasil"
    t.string "zipcode"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city", "state"], name: "index_addresses_on_city_and_state"
    t.index ["city"], name: "index_addresses_on_city"
    t.index ["neighborhood"], name: "index_addresses_on_neighborhood"
    t.index ["property_id"], name: "index_addresses_on_property_id", unique: true
    t.index ["state"], name: "index_addresses_on_state"
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "properties", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "category_id", null: false
    t.string "status", null: false
    t.integer "rooms", null: false
    t.integer "bathrooms", null: false
    t.integer "area", null: false
    t.integer "parking_slots"
    t.boolean "furnished", default: false, null: false
    t.string "contract_type", null: false
    t.string "code"
    t.decimal "promotional_price", precision: 10, scale: 2
    t.date "available_from"
    t.jsonb "rooms_list", default: [], null: false
    t.string "apartment_amenities", default: [], null: false, array: true
    t.string "building_characteristics", default: [], null: false, array: true
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["apartment_amenities"], name: "index_properties_on_apartment_amenities", using: :gin
    t.index ["bathrooms"], name: "index_properties_on_bathrooms"
    t.index ["building_characteristics"], name: "index_properties_on_building_characteristics", using: :gin
    t.index ["category_id"], name: "index_properties_on_category_id"
    t.index ["code"], name: "index_properties_on_code"
    t.index ["created_at"], name: "index_properties_on_created_at"
    t.index ["furnished"], name: "index_properties_on_furnished"
    t.index ["parking_slots"], name: "index_properties_on_parking_slots"
    t.index ["price"], name: "index_properties_on_price"
    t.index ["rooms"], name: "index_properties_on_rooms"
    t.index ["status"], name: "index_properties_on_status"
    t.check_constraint "contract_type::text = ANY (ARRAY['rent'::character varying::text, 'sale'::character varying::text, 'seasonal'::character varying::text])", name: "chk_properties_contract_type"
    t.check_constraint "status::text = ANY (ARRAY['available'::character varying::text, 'unavailable'::character varying::text, 'rented'::character varying::text, 'sold'::character varying::text, 'maintenance'::character varying::text, 'archived'::character varying::text])", name: "chk_properties_status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "properties"
  add_foreign_key "properties", "categories"
end
