# Load the test_helper.rb file so we have access to all the base test setup,
# helper methods, and Rails configuration needed for testing.
require "test_helper"

# Define a test class for the Task model that inherits from ActiveSupport::TestCase.
# This tells Rails "these are tests for our Task model."
# Inheriting gives us access to assert methods, fixtures, and parallel test support.
class TaskTest < ActiveSupport::TestCase
  # Clear all tasks before each test to avoid interference from fixtures and seeds
  setup do
    Task.delete_all
  end

  # This test checks that a Task can be created successfully when it has valid data.
  # It creates a new Task with a name and a "done" status of false, then asserts
  # that the task is valid (passes all validation rules).
  test "should be valid with valid attributes" do
    task = Task.new(name: "Test task", done: false)
    assert task.valid?
  end

  # This test checks that a Task MUST have a name — you can't leave it empty.
  # It tries to create a Task with name set to nil (no value at all),
  # then asserts the task is NOT valid. It also checks that the specific
  # error message "can't be blank" is present on the name field.
  test "should require name" do
    task = Task.new(name: nil, done: false)
    assert_not task.valid?
    assert_includes task.errors[:name], "can't be blank"
  end

  # This test checks that a name made up of only spaces is also rejected.
  # Even though it's technically "not nil," whitespace-only names aren't useful.
  # The model should trim or reject these, and the same "can't be blank" error applies.
  test "should require non-blank name" do
    task = Task.new(name: "   ", done: false)
    assert_not task.valid?
    assert_includes task.errors[:name], "can't be blank"
  end

  # This test checks that names longer than 255 characters are rejected.
  # "a" * 256 creates a string of 256 letter "a"s. The model has a length
  # validation that should reject anything over 255 characters to keep
  # the database and UI clean.
  test "should reject name longer than 255 characters" do
    task = Task.new(name: "a" * 256, done: false)
    assert_not task.valid?
    assert_includes task.errors[:name], "is too long (maximum is 255 characters)"
  end

  # This test checks that a name of exactly 255 characters IS accepted.
  # Since 255 is the maximum allowed length, it should pass validation.
  # This is the boundary test — making sure the limit itself works correctly.
  test "should accept name of exactly 255 characters" do
    task = Task.new(name: "a" * 255, done: false)
    assert task.valid?
  end

  # This test checks that the "done" field must be a proper boolean (true or false).
  # Setting done to nil (neither true nor false) should fail validation.
  # The error "is not included in the list" means the value wasn't one of the allowed options.
  test "should require done to be boolean" do
    task = Task.new(name: "Test", done: nil)
    assert_not task.valid?
    assert_includes task.errors[:done], "is not included in the list"
  end

  # This test checks that leading and trailing whitespace is removed from the name.
  # "  Buy milk  " has extra spaces, but after saving, the task should store "Buy milk".
  # The create! method saves to the database (the bang ! raises an error if it fails).
  # We then reload from the database and verify the spaces were stripped.
  test "should strip whitespace from name" do
    task = Task.create!(name: "  Buy milk  ", done: false)
    assert_equal "Buy milk", task.name
  end

  # This test checks the "completed" scope (a query helper on the Task model).
  # A scope is a reusable database query. The completed scope should return
  # only tasks where done is true. We create one done and one pending task,
  # then verify only the done one is returned.
  test "completed scope returns only done tasks" do
    Task.create!(name: "Done task", done: true)
    Task.create!(name: "Pending task", done: false)
    assert_equal 1, Task.completed.count
    assert Task.completed.first.done?
  end

  # This test checks the "pending" scope, which should return only undone tasks.
  # It's the opposite of the completed scope. We create one of each,
  # then verify only the undone task shows up in the pending results.
  test "pending scope returns only undone tasks" do
    Task.create!(name: "Done task", done: true)
    Task.create!(name: "Pending task", done: false)
    assert_equal 1, Task.pending.count
    assert_not Task.pending.first.done?
  end

  # This is a basic integration test that verifies we can save a Task to the
  # database and then find it again using its ID. It checks that both the
  # name and done status were stored correctly. This catches issues with
  # database configuration or model setup.
  test "should save and retrieve task" do
    task = Task.create!(name: "Integration test", done: false)
    found = Task.find(task.id)
    assert_equal "Integration test", found.name
    assert_equal false, found.done
  end

  # This test checks that an empty-string category is normalized to nil, so a task
  # with no category is consistently nil rather than a mix of nil and "".
  test "normalizes blank category to nil" do
    task = Task.create!(name: "No category task", done: false, category: "  ")
    assert_nil task.category
  end

  # This test checks that category, like name, gets stray whitespace trimmed off.
  test "strips whitespace from category" do
    task = Task.create!(name: "Task", done: false, category: "  Work  ")
    assert_equal "Work", task.category
  end

  # This test checks that a category longer than 100 characters is rejected, mirroring
  # the length cap on "name" so this column can't grow unbounded either.
  test "rejects category longer than 100 characters" do
    task = Task.new(name: "Task", done: false, category: "a" * 101)
    assert_not task.valid?
    assert_includes task.errors[:category], "is too long (maximum is 100 characters)"
  end

  # This test checks the "in_category" scope: given a category, it should return only
  # tasks with that exact category, and given a blank value, it should return everything.
  test "in_category scope filters by exact category" do
    work = Task.create!(name: "Work task", done: false, category: "Work")
    Task.create!(name: "Home task", done: false, category: "Home")

    assert_equal [ work ], Task.in_category("Work").to_a
    assert_equal 2, Task.in_category(nil).count
    assert_equal 2, Task.in_category("").count
  end

  # This test checks the "search" scope: it should match tasks whose name OR category
  # contains the query, case-insensitively, and leave everything in when the query is blank.
  test "search scope matches name or category case-insensitively" do
    groceries = Task.create!(name: "Buy Groceries", done: false)
    Task.create!(name: "Walk the dog", done: false, category: "Home")
    work_task = Task.create!(name: "Ship the report", done: false, category: "Work")

    assert_equal [ groceries ], Task.search("groceries").to_a
    assert_equal [ work_task ], Task.search("WORK").to_a
    assert_equal 3, Task.search(nil).count
    assert_equal 3, Task.search("").count
  end

  # This test checks that "%" and "_" in a search query are treated as literal characters,
  # not SQL LIKE wildcards - otherwise searching for something like "50%" would match
  # far more than intended.
  test "search scope escapes LIKE wildcard characters" do
    Task.create!(name: "Discount 50%", done: false)
    Task.create!(name: "Totally unrelated", done: false)

    assert_equal 1, Task.search("50%").count
  end

  # This test checks the "categories" scope: it should return every distinct, non-blank
  # category in use, sorted alphabetically, without duplicates.
  test "categories scope returns distinct sorted category names" do
    Task.create!(name: "Task 1", done: false, category: "Work")
    Task.create!(name: "Task 2", done: false, category: "Home")
    Task.create!(name: "Task 3", done: false, category: "Work")
    Task.create!(name: "Task 4", done: false)

    assert_equal [ "Home", "Work" ], Task.categories
  end
end
