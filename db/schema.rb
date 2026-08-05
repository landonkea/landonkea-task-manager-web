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
ActiveRecord::Schema[8.1].define(version: 2026_08_03_211845) do
  # Create a new database table called "recurring_tasks" - each row is a template that
  # knows how to spawn regular Task rows on a repeating schedule (see app/models/recurring_task.rb).
  create_table "recurring_tasks", force: :cascade do |t|
    # Whether this template is currently generating tasks on schedule (true) or paused (false).
    t.boolean "active", default: true, null: false
    # When this recurring task template was first created.
    t.datetime "created_at", null: false
    # The "N" in "every N days/weeks/months" - how many units between occurrences.
    t.integer "interval_count", default: 1, null: false
    # Which unit of time the schedule repeats in, stored as an integer enum
    # (0 = daily, 1 = weekly, 2 = monthly - see RecurringTask's `enum :interval_unit`).
    t.integer "interval_unit", default: 1, null: false
    # The name copied onto every Task this template generates, e.g. "Water the plants".
    t.string "name", null: false
    # The next date this template is due to generate a Task.
    t.date "next_run_on", null: false
    # When this recurring task template was last changed.
    t.datetime "updated_at", null: false
    # Index next_run_on because the generator job's core query filters on it every run.
    t.index ["next_run_on"], name: "index_recurring_tasks_on_next_run_on"
  end
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
    # Add a "name" column that stores text strings (up to 255 characters by default).
    # This is the human-readable title of the task, like "Buy groceries".
    t.string "name"
    # Optional link back to the RecurringTask template that generated this task, if any -
    # nil for tasks a person created by hand (see Task's `belongs_to :recurring_task, optional: true`).
    t.integer "recurring_task_id"
    # Add an "updated_at" column that stores a date and time.
    # null: false means every row MUST have a value here.
    # This column tracks the last time any change was made to the task.
    t.datetime "updated_at", null: false
    # Index recurring_task_id so "which tasks did this template generate" is a fast lookup.
    t.index ["recurring_task_id"], name: "index_tasks_on_recurring_task_id"
  end
  # Enforce at the database level that a task's recurring_task_id, when present, must
  # point at a real row in "recurring_tasks".
  add_foreign_key "tasks", "recurring_tasks"
# End of the schema definition block.
end
