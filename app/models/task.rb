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

  # Categories are optional, but if one is given it shouldn't be an absurdly long string -
  # this mirrors the length cap on "name" and keeps the category badge/filter dropdown sane.
  validates :category, length: { maximum: 100 }, allow_blank: true

  # This creates a shortcut called "completed" that finds all tasks where done is true.
  # Instead of writing Task.where(done: true) everywhere, you can just write Task.completed.
  # The "-> { }" is called a lambda — it's a small chunk of code that runs on demand.
  scope :completed, -> { where(done: true) }

  # This creates another shortcut called "pending" that finds all tasks where done is false.
  # Same idea as above — it keeps your code clean and readable.
  scope :pending, -> { where(done: false) }

  # This creates a shortcut called "in_category" that finds all tasks matching a given
  # category string exactly. Used by the index page's category filter dropdown.
  # If "category" is blank, we don't want to filter at all - "where(category: nil)" would
  # wrongly return only uncategorized tasks - so blank input just returns every task.
  scope :in_category, ->(category) { category.present? ? where(category: category) : all }

  # This creates a shortcut called "search" that finds tasks whose name OR category
  # contains the given text, case-insensitively. It's a simple filtered search - not a
  # full-text search engine - which is plenty for a personal task list.
  #
  # "sanitize_sql_like" escapes any "%", "_", or "\" characters in the user's input with
  # a backslash so they can't be used as SQL LIKE wildcards (e.g. searching for "50%"
  # shouldn't match everything) - the "ESCAPE '\'" clause below is what tells the database
  # to treat that backslash as an escape character rather than a literal one.
  # LOWER(...) LIKE LOWER(...) makes the match case-insensitive on both SQLite and
  # Postgres without relying on Postgres-only ILIKE.
  scope :search, ->(query) {
    if query.present?
      pattern = "%#{sanitize_sql_like(query.strip)}%"
      where(
        "LOWER(name) LIKE LOWER(:pattern) ESCAPE '\\' OR LOWER(category) LIKE LOWER(:pattern) ESCAPE '\\'",
        pattern: pattern
      )
    else
      all
    end
  }

  # This creates a shortcut called "categories" that returns every distinct, non-blank
  # category currently in use, sorted alphabetically. It powers the index page's
  # category filter dropdown so it only ever lists categories that actually exist.
  scope :categories, -> { where.not(category: [ nil, "" ]).distinct.order(:category).pluck(:category) }

  # This says: "Before checking if a task is valid, run the strip_whitespace_from_name method."
  # "before_validation" is a Rails callback — it's code that runs automatically at a specific moment.
  before_validation :strip_whitespace_from_name

  # Before saving, clean up the category the same way: trim stray whitespace, and turn an
  # empty string (e.g. a blank dropdown/text field submitted from a form) into a real nil
  # so "uncategorized" tasks are consistently nil rather than a mix of nil and "".
  before_validation :normalize_category

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

  # Strips whitespace from category the same way, and converts "" to nil so a task with
  # no category set is always nil, never an empty string.
  def normalize_category
    stripped = category&.strip
    self.category = stripped.presence
  end
end
