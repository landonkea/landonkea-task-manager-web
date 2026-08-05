# A migration is a Ruby class that tells Rails how to change the database.
# This migration creates the "recurring_tasks" table — each row is a *template* that
# knows how to spawn regular Task rows on a repeating schedule (e.g. "every 1 week").
# It inherits from ActiveRecord::Migration[8.1], matching the Rails version this app targets.
class CreateRecurringTasks < ActiveRecord::Migration[8.1]
  # The "change" method describes what to do; Rails knows how to reverse it automatically.
  def change
    # Create a new database table called "recurring_tasks".
    # Rails automatically adds an "id" column (a unique number for each row).
    create_table :recurring_tasks do |t|
      # The name to give every Task generated from this template, e.g. "Water the plants".
      # null: false means every recurring task MUST have a name — mirrors Task#name.
      t.string :name, null: false

      # interval_unit stores which unit of time the schedule repeats in (day/week/month).
      # It's an integer under the hood so the RecurringTask model can expose it as an
      # enum (interval_unit: "weekly" in Ruby, 1 in the database) - see app/models/recurring_task.rb.
      # default: 1 means "weekly" unless told otherwise (the most common cadence for chores).
      t.integer :interval_unit, null: false, default: 1

      # interval_count is the "1" in "every 1 week" - it lets a schedule be "every 2 weeks"
      # or "every 3 days" instead of only ever firing on every single unit.
      # default: 1 covers the common case (every single day/week/month).
      t.integer :interval_count, null: false, default: 1

      # next_run_on is the next date this template is due to generate a Task.
      # The generator job looks for recurring_tasks where next_run_on <= today, generates
      # a Task, then pushes this date forward by interval_count * interval_unit.
      t.date :next_run_on, null: false

      # active lets a user pause a recurring template without deleting it (and losing its
      # schedule/history) - a paused template is simply skipped by the generator job.
      # default: true means new templates start out active/live.
      t.boolean :active, null: false, default: true

      # Automatically add "created_at" and "updated_at" timestamp columns.
      t.timestamps
    end

    # Index next_run_on because the generator job's core query is
    # "find every active template whose next_run_on has arrived" - this runs on every
    # scheduled sweep, so it should hit an index rather than scan the whole table.
    add_index :recurring_tasks, :next_run_on
  end
end
