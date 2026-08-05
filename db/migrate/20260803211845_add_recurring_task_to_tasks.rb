# This migration links Task rows back to the RecurringTask template that generated them.
# It's an optional (nullable) reference — most tasks are created by hand and have no
# template at all, so we can't require every task to have one.
class AddRecurringTaskToTasks < ActiveRecord::Migration[8.1]
  def change
    # add_reference adds a "recurring_task_id" integer column to "tasks", plus an index
    # on it (index: true is the default) so "show me every task this template generated"
    # is a fast lookup rather than a table scan.
    #
    # null: true (the default, spelled out here for clarity) means a task doesn't need a
    # recurring_task - manually created tasks simply leave this blank.
    #
    # foreign_key: true tells the database itself to enforce that recurring_task_id, when
    # present, must point at a real row in "recurring_tasks" - this catches bugs (like a
    # typo'd ID) at the database level instead of silently storing garbage.
    add_reference :tasks, :recurring_task, null: true, foreign_key: true
  end
end
