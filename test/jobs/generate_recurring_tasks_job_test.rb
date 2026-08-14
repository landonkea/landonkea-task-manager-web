require "test_helper"

# Tests for GenerateRecurringTasksJob - the scheduled job (see config/recurring.yml)
# that sweeps active, due RecurringTask templates and spawns a Task from each one.
class GenerateRecurringTasksJobTest < ActiveJob::TestCase
  setup do
    Task.delete_all
    RecurringTask.delete_all
  end

  test "generates a task for a due, active template" do
    RecurringTask.create!(name: "Water the plants", interval_unit: "weekly", interval_count: 1, next_run_on: 1.day.ago.to_date, active: true)

    assert_difference("Task.count", 1) do
      GenerateRecurringTasksJob.perform_now
    end

    assert_equal "Water the plants", Task.last.name
  end

  test "skips templates that are not due yet" do
    RecurringTask.create!(name: "Future thing", interval_unit: "daily", interval_count: 1, next_run_on: 3.days.from_now.to_date, active: true)

    assert_no_difference("Task.count") do
      GenerateRecurringTasksJob.perform_now
    end
  end

  test "skips paused templates even if due" do
    RecurringTask.create!(name: "Paused thing", interval_unit: "daily", interval_count: 1, next_run_on: 1.day.ago.to_date, active: false)

    assert_no_difference("Task.count") do
      GenerateRecurringTasksJob.perform_now
    end
  end

  test "generates one task per due template and advances each one's schedule" do
    RecurringTask.create!(name: "First", interval_unit: "daily", interval_count: 1, next_run_on: 1.day.ago.to_date, active: true)
    RecurringTask.create!(name: "Second", interval_unit: "daily", interval_count: 1, next_run_on: Date.current, active: true)

    assert_difference("Task.count", 2) do
      GenerateRecurringTasksJob.perform_now
    end

    assert_equal [ "First", "Second" ].sort, Task.pluck(:name).sort
    assert RecurringTask.due_for_generation.none?
  end
end
