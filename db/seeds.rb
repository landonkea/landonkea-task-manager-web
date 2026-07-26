# Seeds are sample data that get loaded into your database for development/testing.
# This file runs when you execute `bin/rails db:seed` or `bin/rails db:setup`.
# Having sample data means you can see and test your app right away without
# manually creating every record.

# Create an array (a list) of hashes (key-value pairs).
# Each hash represents one task with a "name" (string) and "done" (boolean).
# Two tasks start as "done: true" so you can see both completed and incomplete tasks.
tasks = [
  { name: "Set up project repository", done: true },
  { name: "Configure development environment", done: true },
  { name: "Design database schema", done: false },
  { name: "Build user authentication", done: false },
  { name: "Write API endpoints", done: false },
  { name: "Add test coverage", done: false },
  { name: "Set up CI/CD pipeline", done: false },
  { name: "Deploy to production", done: false }
]

# Loop through each hash in the tasks array.
# The variable "task_attrs" holds the current hash on each iteration.
tasks.each do |task_attrs|
  # find_or_create_by! looks for a task with the given name first.
  # If one exists, it returns that existing task (no duplicate created).
  # If none exists, it creates a new one with the given attributes.
  # The ! means it raises an error if something goes wrong (safer for debugging).
  # The block receives the newly-built task so we can set additional attributes.
  Task.find_or_create_by!(name: task_attrs[:name]) do |task|
    # Set the "done" attribute on the task to the value from our seed data.
    # task_attrs[:name] is Ruby hash lookup syntax — it gets the value for the :name key.
    task.done = task_attrs[:done]
  end
end

# Print a confirmation message to the terminal showing how many tasks are now in the database.
# Task.count queries the database and returns the total number of task rows.
puts "Seeded #{Task.count} tasks."
