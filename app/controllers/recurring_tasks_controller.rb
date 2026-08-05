# This file is the RecurringTasksController — it handles all incoming web requests
# related to recurring task templates (the "recipes" that automatically spawn regular
# Task rows on a schedule). It mirrors the structure of TasksController.
class RecurringTasksController < ApplicationController
  # This says: "Before running show, edit, update, destroy, or run_now, first run
  # set_recurring_task." This avoids repeating the same lookup code in every method.
  before_action :set_recurring_task, only: %i[ show edit update destroy run_now ]

  # --- INDEX ACTION ---
  # GET /recurring_tasks
  # Lists every recurring task template, newest first, so newly added schedules are easy
  # to find without hunting through the whole list.
  def index
    @recurring_tasks = RecurringTask.all.order(created_at: :desc)
  end

  # --- SHOW ACTION ---
  # GET /recurring_tasks/1
  # @recurring_task is already loaded by set_recurring_task, so nothing extra is needed
  # here - the view can also list the tasks this template has generated so far.
  def show
    @generated_tasks = @recurring_task.tasks.order(created_at: :desc)
  end

  # --- NEW ACTION ---
  # GET /recurring_tasks/new
  # Builds a blank template, defaulting next_run_on to today so a new schedule starts
  # generating right away unless the user picks a later date.
  def new
    @recurring_task = RecurringTask.new(next_run_on: Date.current)
  end

  # --- EDIT ACTION ---
  # GET /recurring_tasks/1/edit
  def edit
  end

  # --- CREATE ACTION ---
  # POST /recurring_tasks
  def create
    @recurring_task = RecurringTask.new(recurring_task_params)

    respond_to do |format|
      if @recurring_task.save
        format.html { redirect_to @recurring_task, notice: "Recurring task was successfully created." }
        format.json { render :show, status: :created, location: @recurring_task }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @recurring_task.errors, status: :unprocessable_content }
      end
    end
  end

  # --- UPDATE ACTION ---
  # PATCH/PUT /recurring_tasks/1
  def update
    respond_to do |format|
      if @recurring_task.update(recurring_task_params)
        format.html { redirect_to @recurring_task, notice: "Recurring task was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @recurring_task }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @recurring_task.errors, status: :unprocessable_content }
      end
    end
  end

  # --- DESTROY ACTION ---
  # DELETE /recurring_tasks/1
  # Destroying a template does NOT delete the tasks it already generated - see the
  # dependent: :nullify on RecurringTask#tasks - it only stops future generation.
  def destroy
    @recurring_task.destroy!

    respond_to do |format|
      format.html { redirect_to recurring_tasks_path, notice: "Recurring task was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # --- RUN NOW ACTION ---
  # POST /recurring_tasks/1/run_now
  # Manually generates one Task from this template immediately, without waiting for the
  # next scheduled sweep (GenerateRecurringTasksJob, which runs every 15 minutes - see
  # config/recurring.yml). This also advances next_run_on the same way the scheduled job
  # does, so running it early doesn't cause a duplicate occurrence later.
  def run_now
    task = @recurring_task.generate_task!
    redirect_to @recurring_task, notice: "Generated \"#{task.name}\" and rescheduled for #{@recurring_task.next_run_on.to_fs(:long)}."
  end

  private

    # This method finds a recurring task by its ID from the URL parameters and stores it
    # in @recurring_task. Runs automatically before show, edit, update, destroy, run_now.
    def set_recurring_task
      @recurring_task = RecurringTask.find(params.expect(:id))
    end

    # This method defines which form fields are allowed to be saved to the database.
    # It ONLY permits "name", "interval_unit", "interval_count", "next_run_on", and
    # "active" — anything else in the form is ignored, which prevents hackers from
    # injecting fields like recurring_task_id relationships some other way.
    def recurring_task_params
      params.expect(recurring_task: [ :name, :interval_unit, :interval_count, :next_run_on, :active ])
    end
end
