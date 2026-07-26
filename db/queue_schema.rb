# This schema file defines the database tables used by Solid Queue.
# Solid Queue is Rails' built-in database-backed job queue.
# Background jobs let your app do slow work (like sending emails or processing
# uploads) without making the user wait. Solid Queue stores jobs in the database
# instead of using Redis or Sidekiq.

# Tell Rails which schema format version we are using (7.1).
# The define block opens the section where we describe all queue tables.
ActiveRecord::Schema[7.1].define(version: 1) do

  # --- BLOCKED EXECUTIONS TABLE ---
  # This table holds jobs that are temporarily blocked because of concurrency limits.
  # For example, if only one import should run at a time, the second one goes here.
  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    # "job_id" links this blocked execution back to the actual job in solid_queue_jobs.
    # bigint means a very large integer (64-bit) to support millions of jobs.
    t.bigint "job_id", null: false
    # "queue_name" is the name of the queue this job belongs to, like "default" or "mailers".
    # Different queues can have different priorities and processing speeds.
    t.string "queue_name", null: false
    # "priority" determines the order jobs are picked up. Higher number = higher priority.
    # default: 0 means jobs start at priority zero if not specified.
    t.integer "priority", default: 0, null: false
    # "concurrency_key" groups jobs that compete with each other.
    # Only one job with the same concurrency key can run at a time.
    t.string "concurrency_key", null: false
    # "expires_at" is when this blocked execution should stop waiting and be removed.
    # This prevents jobs from being stuck forever.
    t.datetime "expires_at", null: false
    # "created_at" records when this blocked execution was created.
    t.datetime "created_at", null: false
    # Index for quickly releasing blocked jobs by concurrency key, priority, and job id.
    t.index [ "concurrency_key", "priority", "job_id" ], name: "index_solid_queue_blocked_executions_for_release"
    # Index for maintenance tasks that clean up expired blocked executions.
    t.index [ "expires_at", "concurrency_key" ], name: "index_solid_queue_blocked_executions_for_maintenance"
    # Unique index on job_id — each job can only have one blocked execution entry.
    t.index [ "job_id" ], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  # --- CLAIMED EXECUTIONS TABLE ---
  # This table tracks jobs that a worker process has "claimed" and is currently running.
  # It helps the system know which worker is processing which job.
  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    # "job_id" links back to the job definition in solid_queue_jobs.
    t.bigint "job_id", null: false
    # "process_id" identifies which worker process claimed this job.
    # It's a foreign key linking to the solid_queue_processes table.
    # It can be nil if the process has died or the job was orphaned.
    t.bigint "process_id"
    # "created_at" records when this execution was claimed.
    t.datetime "created_at", null: false
    # Unique index on job_id — each job can only be claimed once at a time.
    t.index [ "job_id" ], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    # Composite index on process_id and job_id for looking up all jobs a process has claimed.
    t.index [ "process_id", "job_id" ], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  # --- FAILED EXECUTIONS TABLE ---
  # This table stores jobs that errored out during execution.
  # It captures the error so developers can investigate what went wrong.
  create_table "solid_queue_failed_executions", force: :cascade do |t|
    # "job_id" links back to the failed job in solid_queue_jobs.
    t.bigint "job_id", null: false
    # "error" stores the error message or stack trace from the failure.
    # text type allows very long strings (no practical limit).
    t.text "error"
    # "created_at" records when the failure occurred.
    t.datetime "created_at", null: false
    # Unique index on job_id — each job can only have one failure record.
    t.index [ "job_id" ], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  # --- JOBS TABLE ---
  # This is the main table that stores all job definitions.
  # Every background job in your app gets a row here.
  create_table "solid_queue_jobs", force: :cascade do |t|
    # "queue_name" is the queue this job belongs to (e.g., "default", "mailers", "urgent").
    t.string "queue_name", null: false
    # "class_name" is the Ruby class that defines what the job does.
    # For example, "SendWelcomeEmailJob" — Rails looks this up to run the job.
    t.string "class_name", null: false
    # "arguments" stores the parameters the job needs, serialized as text.
    # For example, a user ID or file path that the job needs to process.
    t.text "arguments"
    # "priority" determines execution order. Higher values = run sooner.
    # default: 0 means standard priority if not specified.
    t.integer "priority", default: 0, null: false
    # "active_job_id" links to Rails' Active Job framework for compatibility.
    # This lets you use Rails' built-in job features alongside Solid Queue.
    t.string "active_job_id"
    # "scheduled_at" is when a delayed job should start running.
    # If nil, the job is ready to run immediately.
    t.datetime "scheduled_at"
    # "finished_at" records when the job completed (successfully or not).
    # If nil, the job hasn't finished yet.
    t.datetime "finished_at"
    # "concurrency_key" groups jobs for concurrency limiting.
    # Jobs with the same key compete to run — only one at a time.
    t.string "concurrency_key"
    # "created_at" records when the job was first added to the queue.
    t.datetime "created_at", null: false
    # "updated_at" records the last time the job row was modified.
    t.datetime "updated_at", null: false
    # Index on active_job_id for looking up jobs by their Active Job identifier.
    t.index [ "active_job_id" ], name: "index_solid_queue_jobs_on_active_job_id"
    # Index on class_name so you can quickly find all jobs of a specific type.
    t.index [ "class_name" ], name: "index_solid_queue_jobs_on_class_name"
    # Index on finished_at for quickly finding completed jobs.
    t.index [ "finished_at" ], name: "index_solid_queue_jobs_on_finished_at"
    # Composite index for filtering jobs by queue name and completion status.
    t.index [ "queue_name", "finished_at" ], name: "index_solid_queue_jobs_for_filtering"
    # Composite index for alerting on jobs that are scheduled but haven't finished.
    t.index [ "scheduled_at", "finished_at" ], name: "index_solid_queue_jobs_for_alerting"
  end

  # --- PAUSES TABLE ---
  # This table tracks queues that have been paused (temporarily stopped from processing).
  # When a queue is paused, no jobs from that queue will run until it's unpaused.
  create_table "solid_queue_pauses", force: :cascade do |t|
    # "queue_name" identifies which queue is paused.
    t.string "queue_name", null: false
    # "created_at" records when the pause was created.
    t.datetime "created_at", null: false
    # Unique index on queue_name — a queue can only be paused once.
    t.index [ "queue_name" ], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  # --- PROCESSES TABLE ---
  # This table tracks all the worker processes that are running your jobs.
  # Each worker process registers itself here so the system knows it's alive.
  create_table "solid_queue_processes", force: :cascade do |t|
    # "kind" describes the type of process (e.g., "Worker" or "Supervisor").
    t.string "kind", null: false
    # "last_heartbeat_at" records the last time this process checked in.
    # If it's been too long, the system assumes the process has crashed.
    t.datetime "last_heartbeat_at", null: false
    # "supervisor_id" links to another process that is supervising this one.
    # A supervisor monitors workers and restarts them if they crash.
    # It can be nil if this process has no supervisor.
    t.bigint "supervisor_id"
    # "pid" is the operating system's process ID for this worker.
    # This is used to manage (kill, signal) the actual OS process.
    t.integer "pid", null: false
    # "hostname" is the name of the machine running this process.
    # Useful when you have workers on multiple servers.
    t.string "hostname"
    # "metadata" stores extra information about the process as text.
    # This could include version info, configuration, or other details.
    t.text "metadata"
    # "created_at" records when this process first registered itself.
    t.datetime "created_at", null: false
    # "name" is a unique human-readable identifier for this process.
    t.string "name", null: false
    # Index on last_heartbeat_at for finding stale processes that may have crashed.
    t.index [ "last_heartbeat_at" ], name: "index_solid_queue_processes_on_last_heartbeat_at"
    # Unique composite index on name and supervisor_id — process names must be unique per supervisor.
    t.index [ "name", "supervisor_id" ], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    # Index on supervisor_id for finding all workers managed by a specific supervisor.
    t.index [ "supervisor_id" ], name: "index_solid_queue_processes_on_supervisor_id"
  end

  # --- READY EXECUTIONS TABLE ---
  # This table holds jobs that are ready to run immediately.
  # Workers pick jobs from this table when they're free.
  create_table "solid_queue_ready_executions", force: :cascade do |t|
    # "job_id" links back to the job in solid_queue_jobs.
    t.bigint "job_id", null: false
    # "queue_name" identifies which queue this ready execution belongs to.
    t.string "queue_name", null: false
    # "priority" determines the order jobs are picked up. Higher = sooner.
    t.integer "priority", default: 0, null: false
    # "created_at" records when this execution became ready.
    t.datetime "created_at", null: false
    # Unique index on job_id — each job can only be ready once.
    t.index [ "job_id" ], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    # Index on priority and job_id for polling all ready jobs by priority.
    t.index [ "priority", "job_id" ], name: "index_solid_queue_poll_all"
    # Composite index for polling ready jobs filtered by queue name and priority.
    t.index [ "queue_name", "priority", "job_id" ], name: "index_solid_queue_poll_by_queue"
  end

  # --- RECURRING EXECUTIONS TABLE ---
  # This table tracks one-time executions of recurring (scheduled/cron) tasks.
  # Each time a recurring task fires, a record is created here.
  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    # "job_id" links to the job that was created for this recurring execution.
    t.bigint "job_id", null: false
    # "task_key" identifies which recurring task definition triggered this execution.
    t.string "task_key", null: false
    # "run_at" records the exact time this recurring execution was triggered.
    t.datetime "run_at", null: false
    # "created_at" records when this execution record was stored in the database.
    t.datetime "created_at", null: false
    # Unique index on job_id — each job can only be linked to one recurring execution.
    t.index [ "job_id" ], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    # Unique composite index on task_key and run_at — each task can only fire once at a given time.
    t.index [ "task_key", "run_at" ], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  # --- RECURRING TASKS TABLE ---
  # This table defines recurring tasks (like cron jobs) that run on a schedule.
  # For example: "Send daily report every day at 9am".
  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    # "key" is a unique name for this recurring task, like "daily_report".
    t.string "key", null: false
    # "schedule" defines when the task runs, using cron syntax or a simple interval.
    # Examples: "0 9 * * *" (daily at 9am) or "every 30 minutes".
    t.string "schedule", null: false
    # "command" is a shell command to run (alternative to running a Ruby class).
    # limit: 2048 allows up to 2048 characters.
    t.string "command", limit: 2048
    # "class_name" is the Ruby job class to execute (alternative to a shell command).
    t.string "class_name"
    # "arguments" stores the parameters to pass to the job class, serialized as text.
    t.text "arguments"
    # "queue_name" specifies which queue the recurring job should go into.
    t.string "queue_name"
    # "priority" sets how urgent the recurring job is. Higher = more urgent.
    t.integer "priority", default: 0
    # "static" indicates whether this task is defined in code (true) or dynamically (false).
    # default: true means tasks are static by default.
    # null: false means this value must always be set.
    t.boolean "static", default: true, null: false
    # "description" stores a human-readable explanation of what the task does.
    t.text "description"
    # "created_at" records when this recurring task definition was created.
    t.datetime "created_at", null: false
    # "updated_at" records the last time this definition was modified.
    t.datetime "updated_at", null: false
    # Unique index on "key" — each recurring task must have a unique name.
    t.index [ "key" ], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    # Index on "static" for filtering between static and dynamic recurring tasks.
    t.index [ "static" ], name: "index_solid_queue_recurring_tasks_on_static"
  end

  # --- SCHEDULED EXECUTIONS TABLE ---
  # This table holds jobs that are scheduled to run in the future.
  # When the scheduled time arrives, the job moves to the "ready" table.
  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    # "job_id" links to the job in solid_queue_jobs.
    t.bigint "job_id", null: false
    # "queue_name" identifies which queue this scheduled job belongs to.
    t.string "queue_name", null: false
    # "priority" determines execution order once the job becomes ready.
    t.integer "priority", default: 0, null: false
    # "scheduled_at" is the future time when this job should start running.
    t.datetime "scheduled_at", null: false
    # "created_at" records when this scheduled execution was created.
    t.datetime "created_at", null: false
    # Unique index on job_id — each job can only have one scheduled execution.
    t.index [ "job_id" ], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    # Composite index for efficiently finding jobs that are ready to be dispatched.
    t.index [ "scheduled_at", "priority", "job_id" ], name: "index_solid_queue_dispatch_all"
  end

  # --- SEMAPHORES TABLE ---
  # Semaphores control concurrency — they limit how many jobs of a certain type
  # can run at the same time. Think of it like a bathroom key at a restaurant.
  create_table "solid_queue_semaphores", force: :cascade do |t|
    # "key" is a unique name for this semaphore, like "email_send_limit".
    t.string "key", null: false
    # "value" is how many concurrent executions are allowed.
    # default: 1 means only one job at a time unless configured otherwise.
    t.integer "value", default: 1, null: false
    # "expires_at" is when this semaphore should automatically be released.
    # This prevents semaphores from being stuck forever if something crashes.
    t.datetime "expires_at", null: false
    # "created_at" records when this semaphore was created.
    t.datetime "created_at", null: false
    # "updated_at" records the last time this semaphore was modified.
    t.datetime "updated_at", null: false
    # Index on expires_at for cleaning up expired semaphores.
    t.index [ "expires_at" ], name: "index_solid_queue_semaphores_on_expires_at"
    # Composite index on key and value for checking semaphore availability.
    t.index [ "key", "value" ], name: "index_solid_queue_semaphores_on_key_and_value"
    # Unique index on key — each semaphore must have a unique name.
    t.index [ "key" ], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  # --- FOREIGN KEY CONSTRAINTS ---
  # Foreign keys ensure data integrity — they link execution tables back to the jobs table.
  # "on_delete: :cascade" means if a job is deleted, all its execution records are deleted too.
  # This prevents orphaned records that reference non-existent jobs.

  # Blocked executions reference jobs — delete both if the job is removed.
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  # Claimed executions reference jobs — delete both if the job is removed.
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  # Failed executions reference jobs — delete both if the job is removed.
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  # Ready executions reference jobs — delete both if the job is removed.
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  # Recurring executions reference jobs — delete both if the job is removed.
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  # Scheduled executions reference jobs — delete both if the job is removed.
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
# End of the schema definition.
end
