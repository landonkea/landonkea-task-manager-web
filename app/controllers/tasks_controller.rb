# This file is the TasksController — it handles all incoming web requests related to tasks.
# Controllers in Rails decide what happens when a user visits a URL or clicks a button.
# Each method below corresponds to a specific user action (viewing, creating, editing, deleting).

# The TasksController inherits from ApplicationController, which gives it all the
# general settings and behavior defined in that parent class.
class TasksController < ApplicationController
  # This says: "Before running the show, edit, update, or destroy methods, first run set_task."
  # This avoids repeating the same code in multiple methods — it automatically finds the
  # right task from the database based on the URL's ID parameter.
  before_action :set_task, only: %i[ show edit update destroy ]

  # --- INDEX ACTION ---
  # GET /tasks or /tasks.json
  # This handles requests to view the full list of tasks.
  # When a user visits /tasks in their browser, this method runs.
  def index
    # This grabs EVERY task from the database and stores them in @tasks.
    # The "@" makes it an instance variable, which means it can be accessed in the view template.
    # "order(created_at: :desc)" sorts them newest-first, so a freshly added task shows up
    # at the top instead of the list order depending on whatever the database feels like today.
    # ".to_a" runs the query right away and loads the results into a plain Ruby array.
    # We do this (instead of leaving @tasks as a lazy relation) so the counts below and the
    # view's @tasks.each loop reuse the same loaded rows instead of querying the database twice.
    @tasks = Task.all.order(created_at: :desc).to_a

    # These two counts power the "x of y tasks remaining" header on the index page.
    @total_count = @tasks.size
    @remaining_count = @tasks.count { |task| !task.done? }
  end

  # --- SHOW ACTION ---
  # GET /tasks/1 or /tasks/1.json
  # This handles requests to view a single specific task (the one with the given ID).
  # The @task variable is set automatically by the "set_task" callback above.
  # There's no code here because @task is already available for the view to use.
  def show
  end

  # --- NEW ACTION ---
  # GET /tasks/new
  # This handles requests to display the form for creating a new task.
  # It creates a brand-new, empty Task object — the form will use this to build its fields.
  def new
    @task = Task.new
  end

  # --- EDIT ACTION ---
  # GET /tasks/1/edit
  # This handles requests to display the form for editing an existing task.
  # Like "show", @task is already loaded by set_task, so no extra code is needed here.
  def edit
  end

  # --- CREATE ACTION ---
  # POST /tasks or /tasks.json
  # This handles the form submission when a user creates a new task.
  def create
    # This creates a new Task in memory (not yet saved to the database) using the form data.
    # "task_params" is a private method below that only allows safe fields through.
    @task = Task.new(task_params)

    # "respond_to" lets the controller behave differently depending on the request type.
    # If the request is from a web browser (HTML), do one thing. If it's from an API (JSON), do another.
    respond_to do |format|
      # If saving the task to the database succeeds...
      if @task.save
        # For browser users: redirect them to the task's show page with a success message.
        format.html { redirect_to @task, notice: "Task was successfully created." }
        # For API users: send back the task data as JSON with a "201 Created" status code.
        format.json { render :show, status: :created, location: @task }
      else
        # If saving fails (e.g., name was blank), show the "new task" form again so the user can fix errors.
        format.html { render :new, status: :unprocessable_content }
        # For API users: send back the validation errors as JSON so they know what went wrong.
        format.json { render json: @task.errors, status: :unprocessable_content }
      end
    end
  end

  # --- UPDATE ACTION ---
  # PATCH/PUT /tasks/1 or /tasks/1.json
  # This handles the form submission when a user edits an existing task.
  def update
    # Same pattern as "create" — respond differently for browser vs API requests.
    respond_to do |format|
      # Try to update the task with the new form data. @task was already found by set_task above.
      if @task.update(task_params)
        # For browser users: redirect to the task's show page with a success message.
        # "status: :see_other" (HTTP 303) tells the browser to follow the redirect with a GET request.
        format.html { redirect_to @task, notice: "Task was successfully updated.", status: :see_other }
        # For API users: send back the updated task data as JSON with a "200 OK" status.
        format.json { render :show, status: :ok, location: @task }
      else
        # If updating fails, re-show the edit form so the user can fix their input.
        format.html { render :edit, status: :unprocessable_content }
        # For API users: send back the validation errors.
        format.json { render json: @task.errors, status: :unprocessable_content }
      end
    end
  end

  # --- DESTROY ACTION ---
  # DELETE /tasks/1 or /tasks/1.json
  # This handles requests to delete a task permanently from the database.
  def destroy
    # "destroy!" permanently removes the task from the database. The "!" means it will raise
    # an error if something goes wrong (rather than failing silently).
    @task.destroy!

    respond_to do |format|
      # For browser users: send them back to the task list with a success message.
      format.html { redirect_to tasks_path, notice: "Task was successfully destroyed.", status: :see_other }
      # For API users: send back an empty response with no content (204 status) — the deletion succeeded.
      format.json { head :no_content }
    end
  end

  # --- PRIVATE METHODS ---
  # Everything below this line can ONLY be called from inside this controller.
  # These are helper methods that keep the public actions clean and DRY (Don't Repeat Yourself).

  private

    # This method finds a task by its ID from the URL parameters and stores it in @task.
    # "params.expect(:id)" safely extracts the ID and raises an error if it's missing.
    # This runs automatically before show, edit, update, and destroy (because of before_action above).
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params.expect(:id))
    end

    # This method defines which form fields are allowed to be saved to the database.
    # It ONLY permits "name", "done", "due_on", "priority", and "notes" — anything else
    # in the form is ignored. This is a critical security feature that prevents hackers
    # from injecting bad data. Only allow a list of trusted parameters through.
    def task_params
      params.expect(task: [ :name, :done, :due_on, :priority, :notes ])
    end
end
