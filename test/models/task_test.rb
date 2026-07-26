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
end
