# Adds database indexes so common queries don't have to scan every row in the
# "tasks" table. Right now the only index is the automatic one on the primary key.
#
# As the table grows, these columns are exactly the ones we filter and sort by:
#   - done:     the index page's "pending" list filters on this
#   - due_on:   used to sort tasks and find overdue ones
#   - priority: used to sort/filter tasks by priority level
class AddIndexesToTasks < ActiveRecord::Migration[8.1]
  def change
    add_index :tasks, :done
    add_index :tasks, :due_on
    add_index :tasks, :priority
  end
end
