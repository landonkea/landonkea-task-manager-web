# A migration is a Ruby class that tells Rails how to change the database.
# The class name "CreateTasks" describes what this migration does: create the tasks table.
# It inherits from ActiveRecord::Migration[8.1], which means it targets Rails 8.1's
# migration system and gives us helper methods like create_table.
class CreateTasks < ActiveRecord::Migration[8.1]
  # The "change" method is special — it describes what to do, and Rails knows
  # how to reverse it automatically. If you ever roll back, Rails will undo this.
  def change
    # Create a new database table called "tasks".
    # The block |t| gives us a table builder object where we define columns.
    # Rails automatically adds an "id" column (a unique number for each row).
    create_table :tasks do |t|
      # Add a "name" column of type string (text).
      # This will hold the task's title, like "Buy groceries".
      # By default, strings can be up to 255 characters long.
      t.string :name
      # Add a "done" column of type boolean (true/false).
      # This tracks whether the task is completed.
      # It can be nil (unknown), true (done), or false (not done).
      t.boolean :done

      # Automatically add two timestamp columns: "created_at" and "updated_at".
      # Rails will set created_at when the row is first saved, and
      # updated_at every time the row is changed.
      t.timestamps
    end
  end
end
