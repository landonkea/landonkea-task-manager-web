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

# Tell Rails which version of the schema format we are using (8.1 in this case).
# The define block opens a section where we describe all the tables in our database.
# The version number comes from the timestamp of the last migration that ran.
ActiveRecord::Schema[8.1].define(version: 2026_08_03_015257) do
  # Create a new database table called "tasks".
  # force: :cascade means if the table already exists, drop it first, then recreate it.
  # The block |t| gives us a table object we use to define columns.
  create_table "tasks", force: :cascade do |t|
    # Add a "created_at" column that stores a date and time.
    # null: false means every row MUST have a value here — it cannot be empty.
    # This column tracks when each task was first created.
    t.datetime "created_at", null: false
    # Add a "done" column that stores true or false (a boolean).
    # This tracks whether a task has been completed or not.
    # There is no null: false here, so it could technically be nil (unknown).
    t.boolean "done"
    # Add a "due_on" column that stores a date (no time component).
    # This tracks when a task is due - it can be blank for tasks with no deadline.
    t.date "due_on"
    # Add a "name" column that stores text strings (up to 255 characters by default).
    # This is the human-readable title of the task, like "Buy groceries".
    t.string "name"
    # Add a "notes" column that stores longer free-form text than "name" allows.
    # This is optional extra detail about a task - it can be blank.
    t.text "notes"
    # Add a "priority" column that stores an integer (0, 1, or 2).
    # The Task model maps this to an enum: low, medium, high.
    # default: 1 means new rows default to "medium" priority instead of nil.
    # null: false means every row MUST have a priority value.
    t.integer "priority", default: 1, null: false
    # Add an "updated_at" column that stores a date and time.
    # null: false means every row MUST have a value here.
    # This column tracks the last time any change was made to the task.
    t.datetime "updated_at", null: false
    # Index the "done" column so filtering/sorting by completion status stays fast
    # as the tasks table grows.
    t.index ["done"], name: "index_tasks_on_done"
    # Index the "due_on" column so sorting by due date and finding overdue tasks stays fast.
    t.index ["due_on"], name: "index_tasks_on_due_on"
    # Index the "priority" column so sorting/filtering by priority level stays fast.
    t.index ["priority"], name: "index_tasks_on_priority"
  end
# End of the schema definition block.
end
