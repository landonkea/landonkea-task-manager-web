# Load the test_helper.rb file so we have access to all the base test setup,
# helper methods, and Rails configuration needed for testing.
require "test_helper"

# Define integration tests for the TasksController.
# Integration tests simulate a full user experience — they send real HTTP requests
# to your app and check the responses, just like a user clicking around in a browser.
# ActionDispatch::IntegrationTest is Rails' class specifically for this purpose.
class TasksControllerTest < ActionDispatch::IntegrationTest
  # The "setup" block runs BEFORE every single test in this class.
  # Here we load the fixture task named ":one" from tasks.yml into @task.
  # Fixtures are pre-made test data so we don't have to create tasks from scratch each time.
  setup do
    @task = tasks(:one)
    # The task index/show/create/etc. routes now sit behind the authentication gate
    # (see app/controllers/concerns/authentication.rb, included in ApplicationController),
    # so every request in this file needs a signed-in user first - sign_in_as is a test
    # helper from test/test_helpers/session_test_helper.rb that fakes a valid session cookie
    # without going through the actual sign-in form.
    sign_in_as(users(:one))
  end

  # Tests that visiting the tasks list page (index) returns a successful HTTP response.
  # "get" simulates a user navigating to the tasks index URL.
  # "assert_response :success" checks that the page loaded without errors (HTTP 200).
  test "should get index" do
    get tasks_url
    assert_response :success
  end

  # Tests that a signed-out visitor gets redirected to the sign-in page instead of
  # seeing the task list - this is the whole point of the auth gate: the app shouldn't
  # be wide open to anyone who finds the URL.
  test "redirects signed-out visitor to sign in" do
    sign_out
    get tasks_url
    assert_redirected_to new_session_path
  end

  # Tests that the search box (params[:q]) narrows the index down to matching tasks
  # by name, and excludes tasks that don't match.
  test "should filter index by search query" do
    matching = Task.create!(name: "Buy stamps", done: false)
    Task.create!(name: "Walk the dog", done: false)

    get tasks_url, params: { q: "stamps" }

    assert_response :success
    assert_match matching.name, response.body
    assert_no_match(/Walk the dog/, response.body)
  end

  # Tests that the category filter dropdown (params[:category]) narrows the index down
  # to only tasks in that exact category.
  test "should filter index by category" do
    work_task = Task.create!(name: "Ship the report", done: false, category: "Work")
    Task.create!(name: "Buy groceries again", done: false, category: "Home")

    get tasks_url, params: { category: "Work" }

    assert_response :success
    assert_match work_task.name, response.body
    assert_no_match(/Buy groceries again/, response.body)
  end

  # Tests that visiting the "new task" form page works correctly.
  # This is the page where a user would type in a new task name and click submit.
  # A successful response means the form rendered without crashing.
  test "should get new" do
    get new_task_url
    assert_response :success
  end

  # Tests that submitting the new task form actually creates a Task in the database.
  # "assert_difference" checks that Task.count increases by 1 during the block.
  # "post" simulates submitting the form with task data (name and done status).
  # After creating, the user should be redirected to the newly created task's page.
  test "should create task" do
    assert_difference("Task.count") do
      post tasks_url, params: { task: { done: @task.done, name: @task.name } }
    end

    assert_redirected_to task_url(Task.last)
  end

  # Tests that visiting a specific task's page (show) loads successfully.
  # "task_url(@task)" builds the URL for the specific task loaded in setup.
  # A success response means the task detail page rendered correctly.
  test "should show task" do
    get task_url(@task)
    assert_response :success
  end

  # Tests that visiting the edit form for a task loads successfully.
  # This is the page where a user would change the task's name or done status.
  # A success response means the edit form rendered without errors.
  test "should get edit" do
    get edit_task_url(@task)
    assert_response :success
  end

  # Tests that submitting the edit form actually updates the task.
  # "patch" is the HTTP method Rails uses for updates (not GET or POST).
  # After updating, the user should be redirected back to the task's show page.
  test "should update task" do
    patch task_url(@task), params: { task: { done: @task.done, name: @task.name } }
    assert_redirected_to task_url(@task)
  end

  # Tests that deleting a task actually removes it from the database.
  # "assert_difference" with -1 checks that Task.count decreases by 1.
  # "delete" simulates clicking a delete button/link.
  # After deletion, the user is redirected back to the tasks list page.
  test "should destroy task" do
    assert_difference("Task.count", -1) do
      delete task_url(@task)
    end

    assert_redirected_to tasks_url
  end
end
