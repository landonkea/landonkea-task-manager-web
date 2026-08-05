require "test_helper"

# Integration tests for RecurringTasksController - mirrors TasksControllerTest's structure.
class RecurringTasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @recurring_task = recurring_tasks(:weekly_chore)
  end

  test "should get index" do
    get recurring_tasks_url
    assert_response :success
  end

  test "should get new" do
    get new_recurring_task_url
    assert_response :success
  end

  test "should create recurring task" do
    assert_difference("RecurringTask.count") do
      post recurring_tasks_url, params: { recurring_task: { name: "Take out trash", interval_unit: "weekly", interval_count: 1, next_run_on: Date.current, active: true } }
    end

    assert_redirected_to recurring_task_url(RecurringTask.last)
  end

  test "should not create recurring task with invalid attributes" do
    assert_no_difference("RecurringTask.count") do
      post recurring_tasks_url, params: { recurring_task: { name: "", interval_unit: "weekly", interval_count: 1, next_run_on: Date.current } }
    end

    assert_response :unprocessable_content
  end

  test "should show recurring task" do
    get recurring_task_url(@recurring_task)
    assert_response :success
  end

  test "should get edit" do
    get edit_recurring_task_url(@recurring_task)
    assert_response :success
  end

  test "should update recurring task" do
    patch recurring_task_url(@recurring_task), params: { recurring_task: { name: "Water the plants and herbs", interval_unit: @recurring_task.interval_unit, interval_count: @recurring_task.interval_count, next_run_on: @recurring_task.next_run_on, active: @recurring_task.active } }
    assert_redirected_to recurring_task_url(@recurring_task)
    assert_equal "Water the plants and herbs", @recurring_task.reload.name
  end

  test "should destroy recurring task" do
    assert_difference("RecurringTask.count", -1) do
      delete recurring_task_url(@recurring_task)
    end

    assert_redirected_to recurring_tasks_url
  end

  test "run_now generates a task and redirects to the recurring task" do
    assert_difference("Task.count", 1) do
      post run_now_recurring_task_url(@recurring_task)
    end

    assert_redirected_to recurring_task_url(@recurring_task)
  end
end
