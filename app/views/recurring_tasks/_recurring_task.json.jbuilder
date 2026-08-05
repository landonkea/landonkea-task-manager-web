json.extract! recurring_task, :id, :name, :interval_unit, :interval_count, :next_run_on, :active, :created_at, :updated_at
json.url recurring_task_url(recurring_task, format: :json)
