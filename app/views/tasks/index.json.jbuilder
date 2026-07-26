# json.array! tells Jbuilder to build a JSON array (a list in square brackets).
# @tasks is the collection of all tasks from the controller's index action.
# The partial option renders _task.json.jbuilder for each task in the array.
# The as: :task tells Jbuilder to pass each item to the partial as a local variable called "task".
# This produces: [{"id": 1, "name": "...", ...}, {"id": 2, ...}, ...]
json.array! @tasks, partial: "tasks/task", as: :task
