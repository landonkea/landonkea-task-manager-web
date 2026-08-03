# json.extract! is a Jbuilder helper that pulls specific attributes from the task object.
# It creates JSON keys for :id, :name, :done, :category, :created_at, and :updated_at.
# This produces something like: {"id": 1, "name": "Buy groceries", "done": false, ...}
# Jbuilder is Rails' way of building JSON responses in view files rather than controllers.
json.extract! task, :id, :name, :done, :category, :created_at, :updated_at

# json.url adds a "url" key to the JSON response pointing to this task's JSON endpoint.
# task_url(task, format: :json) generates a URL like /tasks/1.json.
json.url task_url(task, format: :json)
