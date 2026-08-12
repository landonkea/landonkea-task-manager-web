# This migration adds a simple "category" column to the tasks table, so tasks can be
# grouped/filtered (e.g. "Work", "Home", "Errands") without needing a separate Tag model
# and join table - a single string column is enough for one category per task, and keeps
# this a MEDIUM-tier feature rather than a full tagging system.
class AddCategoryToTasks < ActiveRecord::Migration[8.1]
  def change
    # A plain string column - optional (no null: false), since not every task needs
    # a category. Blank/nil means "uncategorized".
    add_column :tasks, :category, :string

    # Index it so filtering the task list by category stays fast as the table grows,
    # matching the pattern used for the other filterable columns (done, due_on, priority).
    add_index :tasks, :category
  end
end
