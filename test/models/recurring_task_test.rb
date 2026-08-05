require "test_helper"

# Define a test class for the RecurringTask model that inherits from ActiveSupport::TestCase.
class RecurringTaskTest < ActiveSupport::TestCase
  # Clear all recurring tasks and tasks before each test so fixtures/prior state can't
  # bleed between tests (mirrors the setup pattern in TaskTest).
  setup do
    Task.delete_all
    RecurringTask.delete_all
  end

  test "should be valid with valid attributes" do
    recurring_task = RecurringTask.new(name: "Water the plants", interval_unit: "weekly", interval_count: 1, next_run_on: Date.current)
    assert recurring_task.valid?
  end

  test "should require name" do
    recurring_task = RecurringTask.new(name: nil, interval_unit: "weekly", interval_count: 1, next_run_on: Date.current)
    assert_not recurring_task.valid?
    assert_includes recurring_task.errors[:name], "can't be blank"
  end

  test "should require next_run_on" do
    recurring_task = RecurringTask.new(name: "Test", interval_unit: "weekly", interval_count: 1, next_run_on: nil)
    assert_not recurring_task.valid?
    assert_includes recurring_task.errors[:next_run_on], "can't be blank"
  end

  test "should require interval_count to be a positive integer" do
    recurring_task = RecurringTask.new(name: "Test", interval_unit: "weekly", interval_count: 0, next_run_on: Date.current)
    assert_not recurring_task.valid?
    assert_includes recurring_task.errors[:interval_count], "must be greater than 0"
  end

  test "should reject a negative interval_count" do
    recurring_task = RecurringTask.new(name: "Test", interval_unit: "weekly", interval_count: -1, next_run_on: Date.current)
    assert_not recurring_task.valid?
  end

  test "should reject an invalid interval_unit" do
    recurring_task = RecurringTask.new(name: "Test", interval_unit: "yearly", interval_count: 1, next_run_on: Date.current)
    assert_not recurring_task.valid?
    assert_includes recurring_task.errors[:interval_unit], "is not included in the list"
  end

  test "active scope returns only non-paused templates" do
    RecurringTask.create!(name: "Active one", interval_unit: "daily", interval_count: 1, next_run_on: Date.current, active: true)
    RecurringTask.create!(name: "Paused one", interval_unit: "daily", interval_count: 1, next_run_on: Date.current, active: false)
    assert_equal 1, RecurringTask.active.count
    assert RecurringTask.active.first.active?
  end

  test "due scope returns only templates whose next_run_on has arrived" do
    RecurringTask.create!(name: "Due", interval_unit: "daily", interval_count: 1, next_run_on: 1.day.ago.to_date, active: true)
    RecurringTask.create!(name: "Not due", interval_unit: "daily", interval_count: 1, next_run_on: 3.days.from_now.to_date, active: true)
    assert_equal 1, RecurringTask.due.count
    assert_equal "Due", RecurringTask.due.first.name
  end

  test "due_for_generation excludes paused templates even if due" do
    RecurringTask.create!(name: "Due but paused", interval_unit: "daily", interval_count: 1, next_run_on: 1.day.ago.to_date, active: false)
    assert_equal 0, RecurringTask.due_for_generation.count
  end

  test "due_for_generation excludes active templates that aren't due yet" do
    RecurringTask.create!(name: "Not due", interval_unit: "daily", interval_count: 1, next_run_on: 3.days.from_now.to_date, active: true)
    assert_equal 0, RecurringTask.due_for_generation.count
  end

  test "due_for_generation returns templates that are both active and due" do
    template = RecurringTask.create!(name: "Ready", interval_unit: "daily", interval_count: 1, next_run_on: Date.current, active: true)
    assert_equal [ template ], RecurringTask.due_for_generation.to_a
  end

  test "generate_task! creates a task with the template's name" do
    template = RecurringTask.create!(name: "Water the plants", interval_unit: "weekly", interval_count: 1, next_run_on: Date.current)

    assert_difference("Task.count", 1) do
      template.generate_task!
    end

    task = Task.last
    assert_equal "Water the plants", task.name
    assert_not task.done?
    assert_equal template, task.recurring_task
  end

  test "generate_task! advances next_run_on for a daily template" do
    template = RecurringTask.create!(name: "Test", interval_unit: "daily", interval_count: 3, next_run_on: Date.current)
    template.generate_task!
    assert_equal Date.current + 3.days, template.next_run_on
  end

  test "generate_task! advances next_run_on for a weekly template" do
    template = RecurringTask.create!(name: "Test", interval_unit: "weekly", interval_count: 2, next_run_on: Date.current)
    template.generate_task!
    assert_equal Date.current + 2.weeks, template.next_run_on
  end

  test "generate_task! advances next_run_on for a monthly template" do
    template = RecurringTask.create!(name: "Test", interval_unit: "monthly", interval_count: 1, next_run_on: Date.current)
    template.generate_task!
    assert_equal Date.current + 1.month, template.next_run_on
  end

  test "generate_task! advances from today, not the old date, when a template was overdue" do
    # next_run_on is far in the past (e.g. the template was paused for a while) -
    # advancing from the OLD date would still leave it overdue; advancing from today
    # means it picks up cleanly going forward instead of dumping a backlog.
    template = RecurringTask.create!(name: "Test", interval_unit: "daily", interval_count: 1, next_run_on: 10.days.ago.to_date)
    template.generate_task!
    assert_equal Date.current + 1.day, template.next_run_on
  end

  test "destroying a recurring task nullifies its generated tasks instead of deleting them" do
    template = RecurringTask.create!(name: "Test", interval_unit: "daily", interval_count: 1, next_run_on: Date.current)
    task = template.generate_task!

    assert_no_difference("Task.count") do
      template.destroy!
    end

    assert_nil task.reload.recurring_task_id
  end
end
