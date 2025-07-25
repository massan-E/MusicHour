# NOTE: Renderではdatabaseを複数持てないのでsolid_cacheのschemaからコピペ
# https://github.com/rails/solid_cache/blob/v1.0.6/lib/generators/solid_cache/install/templates/db/cache_schema.rb
# https://madogiwa0124.hatenablog.com/entry/2025/01/25/230015

class CreateSolidcacheTables < ActiveRecord::Migration[7.2]
  def change
    create_table "solid_cache_entries", force: :cascade do |t|
      t.binary "key", limit: 1024, null: false
      t.binary "value", limit: 536870912, null: false
      t.datetime "created_at", null: false
      t.integer "key_hash", limit: 8, null: false
      t.integer "byte_size", limit: 4, null: false
      t.index [ "byte_size" ], name: "index_solid_cache_entries_on_byte_size"
      t.index [ "key_hash", "byte_size" ], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
      t.index [ "key_hash" ], name: "index_solid_cache_entries_on_key_hash", unique: true
    end
  end
end
