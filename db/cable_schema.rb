# This schema file defines the database tables used by Solid Cable.
# Solid Cable is Rails' built-in replacement for Action Cable's database adapter.
# Action Cable handles real-time WebSocket connections (live updates in the browser).
# Solid Cable stores cable messages in the database instead of using Redis.

# Tell Rails which schema format version we are using (7.1).
# The define block opens the section where we describe the cable tables.
ActiveRecord::Schema[7.1].define(version: 1) do
  # Create a table called "solid_cable_messages".
  # This table stores WebSocket messages that are waiting to be delivered.
  # force: :cascade drops the table first if it already exists.
  create_table "solid_cable_messages", force: :cascade do |t|
    # "channel" stores which WebSocket channel this message belongs to.
    # A channel is like a chat room — e.g., "TaskChannel" for task updates.
    # binary type means raw data; limit: 1024 means up to 1024 bytes.
    # null: false means this column cannot be empty.
    t.binary "channel", limit: 1024, null: false
    # "payload" stores the actual message content (the data being sent).
    # limit: 536870912 allows up to ~512 MB — messages can be very large.
    # null: false means a message must always have content.
    t.binary "payload", limit: 536870912, null: false
    # "created_at" records when the message was stored.
    # null: false ensures every message has a timestamp.
    t.datetime "created_at", null: false
    # "channel_hash" is a numeric fingerprint of the channel name.
    # Using a hash makes database lookups much faster than searching text.
    # limit: 8 means it's stored as a big integer (64-bit).
    t.integer "channel_hash", limit: 8, null: false
    # Create an index on the "channel" column.
    # An index is like a book's index — it speeds up searches on that column.
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    # Create an index on the "channel_hash" column for faster lookups by hash.
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    # Create an index on "created_at" so Rails can quickly find messages by time.
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end
# End of the schema definition.
end
