# This migration adds three new fields to the "tasks" table, all in one change:
#   - due_on:   the date a task is due (used to sort tasks and flag overdue ones)
#   - priority: an integer that maps to a "low"/"medium"/"high" enum on the model
#   - notes:    a free-text field for details that don't fit in the short task name
class AddQuickWinFieldsToTasks < ActiveRecord::Migration[8.1]
  def change
    # A plain date column - no time component, since due dates are day-level, not minute-level.
    add_column :tasks, :due_on, :date

    # Stored as an integer so the Task model can map it to an enum (low: 0, medium: 1, high: 2).
    # default: 1 (medium) means existing tasks and new tasks without an explicit priority
    # land in the middle instead of nil, so the enum lookup never chokes on nil.
    # null: false backs up the model-level presence validation with a real DB constraint.
    add_column :tasks, :priority, :integer, default: 1, null: false

    # A text column (not string) because notes can run longer than the 255-character
    # limit we put on the short "name" field.
    add_column :tasks, :notes, :text
  end
end
