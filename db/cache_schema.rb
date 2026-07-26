# This schema file defines the database tables used by Solid Cache.
# Solid Cache is Rails' built-in database-backed cache store.
# Caching stores frequently accessed data in a fast location so your app
# doesn't have to recalculate or re-fetch it every time.
# Solid Cache stores cached data in your database instead of using Redis or Memcached.

# Tell Rails which schema format version we are using (7.2).
# The define block opens the section where we describe the cache tables.
ActiveRecord::Schema[7.2].define(version: 1) do
  # Create a table called "solid_cache_entries".
  # Each row represents one cached item (one key-value pair).
  # force: :cascade drops the table first if it already exists.
  create_table "solid_cache_entries", force: :cascade do |t|
    # "key" is the name/label used to look up the cached value later.
    # For example, a key might be "user:123:profile".
    # binary type stores raw data; limit: 1024 means up to 1024 bytes.
    # null: false means every cache entry must have a key.
    t.binary "key", limit: 1024, null: false
    # "value" is the actual cached data being stored.
    # limit: 536870912 allows up to ~512 MB — cached data can be very large.
    # null: false means a cache entry must always have a value.
    t.binary "value", limit: 536870912, null: false
    # "created_at" records when this cache entry was stored.
    # null: false ensures every entry has a timestamp.
    t.datetime "created_at", null: false
    # "key_hash" is a numeric fingerprint of the key.
    # Using a hash makes database lookups much faster than searching text.
    # limit: 8 means it's stored as a big integer (64-bit).
    t.integer "key_hash", limit: 8, null: false
    # "byte_size" stores how many bytes the cache entry takes up.
    # This helps Rails decide which entries to evict when the cache is full.
    # limit: 4 means it's stored as a regular integer (32-bit).
    t.integer "byte_size", limit: 4, null: false
    # Index on "byte_size" so Rails can quickly find entries by their size.
    # This is useful for cache eviction (removing old entries to make room).
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    # Composite index on both "key_hash" and "byte_size" together.
    # A composite index covers multiple columns at once for faster combined queries.
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    # Index on "key_hash" with a uniqueness constraint.
    # This ensures no two cache entries can have the same key.
    # The database will raise an error if you try to insert a duplicate.
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end
# End of the schema definition.
end
