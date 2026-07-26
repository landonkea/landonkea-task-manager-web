# json.partial! tells Jbuilder to include another Jbuilder template inside this one.
# "tasks/task" points to the _task.json.jbuilder partial file.
# task: @task passes the current task object to that partial.
# This reuses the same JSON structure defined in _task.json.jbuilder.
# So a show request returns: {"id": 1, "name": "Buy milk", "done": false, "url": "..."}
# Using partials avoids duplicating the JSON field definitions between show and index.
json.partial! "tasks/task", task: @task
