# This file defines the Task model, which represents a single to-do item in our app.
# Models in Rails handle data and business logic — they talk to the "tasks" database table.

# The Task class inherits from ApplicationRecord, which gives it superpowers like
# saving to the database, querying data, and more — all for free.
class Task < ApplicationRecord
  # Optional link back to the RecurringTask template that generated this task, if any.
  # "optional: true" means a task does NOT need a recurring_task - most tasks are created
  # by hand and this stays nil for them. See app/models/recurring_task.rb for the other
  # side of this relationship.
  belongs_to :recurring_task, optional: true

  # This line makes sure a task CANNOT be saved without a name.
  # The "presence: true" rule means the name field must not be blank.
  # The "length" rule means the name must be at least 1 character and at most 255 characters.
  # This prevents empty or absurdly long task names from being saved.
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }

  # This line makes sure the "done" field can ONLY be true or false (nothing else).
  # This is a safety net — it prevents invalid data like "maybe" or "sometimes" from sneaking in.
  validates :done, inclusion: { in: [ true, false ] }

  # This creates a shortcut called "completed" that finds all tasks where done is true.
  # Instead of writing Task.where(done: true) everywhere, you can just write Task.completed.
  # The "-> { }" is called a lambda — it's a small chunk of code that runs on demand.
  scope :completed, -> { where(done: true) }

  # This creates another shortcut called "pending" that finds all tasks where done is false.
  # Same idea as above — it keeps your code clean and readable.
  scope :pending, -> { where(done: false) }

  # This says: "Before checking if a task is valid, run the strip_whitespace_from_name method."
  # "before_validation" is a Rails callback — it's code that runs automatically at a specific moment.
  before_validation :strip_whitespace_from_name

  # The "private" keyword means everything below it can ONLY be called from inside this class.
  # This prevents other parts of your app from accidentally calling this method directly.
  private

  # This method removes any accidental spaces from the beginning or end of the task name.
  # For example, "  Buy milk  " becomes "Buy milk".
  # The "&." is the safe navigation operator — if name is nil, it won't crash, it just returns nil.
  # "self.name =" writes the cleaned-up name back to the task's name field.
  def strip_whitespace_from_name
    self.name = name&.strip
  end
end
