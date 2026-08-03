# This file defines the Task model, which represents a single to-do item in our app.
# Models in Rails handle data and business logic — they talk to the "tasks" database table.

# The Task class inherits from ApplicationRecord, which gives it superpowers like
# saving to the database, querying data, and more — all for free.
class Task < ApplicationRecord
  # This line makes sure a task CANNOT be saved without a name.
  # The "presence: true" rule means the name field must not be blank.
  # The "length" rule means the name must be at least 1 character and at most 255 characters.
  # This prevents empty or absurdly long task names from being saved.
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }

  # This line makes sure the "done" field can ONLY be true or false (nothing else).
  # This is a safety net — it prevents invalid data like "maybe" or "sometimes" from sneaking in.
  validates :done, inclusion: { in: [ true, false ] }

  # This line makes sure "notes" doesn't grow unreasonably large.
  # "allow_blank: true" means an empty or missing notes field is perfectly fine —
  # notes are optional, unlike the task name.
  validates :notes, length: { maximum: 5000 }, allow_blank: true

  # "enum" turns the integer "priority" column into a named, readable concept.
  # Under the hood, the database still stores 0, 1, or 2 — but in Ruby code you get
  # to write task.priority = "high" and call task.high? / task.low? / task.medium?
  # The hash maps each name to the integer it's stored as, so sorting by priority
  # (low: 0 < medium: 1 < high: 2) also sorts by urgency.
  enum :priority, { low: 0, medium: 1, high: 2 }, validate: true

  # This creates a shortcut called "completed" that finds all tasks where done is true.
  # Instead of writing Task.where(done: true) everywhere, you can just write Task.completed.
  # The "-> { }" is called a lambda — it's a small chunk of code that runs on demand.
  scope :completed, -> { where(done: true) }

  # This creates another shortcut called "pending" that finds all tasks where done is false.
  # Same idea as above — it keeps your code clean and readable.
  scope :pending, -> { where(done: false) }

  # This creates a shortcut called "overdue" that finds tasks whose due date has already
  # passed and that aren't marked done yet. A task that's finished is never "overdue" —
  # it's just done. Date.current is today's date on the server, no time component.
  scope :overdue, -> { pending.where(due_on: ...Date.current) }

  # This says: "Before checking if a task is valid, run the strip_whitespace_from_name method."
  # "before_validation" is a Rails callback — it's code that runs automatically at a specific moment.
  before_validation :strip_whitespace_from_name

  # Returns true when this task is overdue: it has a due date, that date is in the
  # past, and the task isn't done yet. Used in the views to show a red "Overdue" badge
  # without duplicating this logic in ERB.
  def overdue?
    due_on.present? && due_on < Date.current && !done?
  end

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
