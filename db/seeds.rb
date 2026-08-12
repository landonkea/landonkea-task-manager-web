# Seeds are sample data that get loaded into your database for development/testing.
# This file runs when you execute `bin/rails db:seed` or `bin/rails db:setup`.
# Having sample data means you can see and test your app right away without
# manually creating every record.

# This app has a minimal SINGLE-USER auth gate (see app/models/user.rb and
# config/routes.rb's `resource :session`) - there's no public signup form, so the one
# account that's allowed to log in has to be created here instead.
#
# The email/password come from ENV variables rather than being hardcoded, so the same
# seed file works in every environment without ever committing a real password to git:
#   - In development, if you don't set them, we fall back to a well-known dev-only login
#     so `bin/rails db:seed` "just works" locally.
#   - In production/staging, ADMIN_EMAIL and ADMIN_PASSWORD should be set as Kamal secrets
#     (see config/deploy.yml) - if they're missing there, we skip creating the user rather
#     than silently seeding a guessable password into a real environment.
admin_email = ENV["ADMIN_EMAIL"]
admin_password = ENV["ADMIN_PASSWORD"]

if admin_email.blank? || admin_password.blank?
  if Rails.env.local?
    admin_email = "admin@example.com"
    admin_password = "password123"
    puts "ADMIN_EMAIL/ADMIN_PASSWORD not set - using dev-only default (admin@example.com / password123)."
  else
    puts "ADMIN_EMAIL/ADMIN_PASSWORD not set - skipping user seed. Set both as Kamal secrets to create the login."
  end
end

if admin_email.present? && admin_password.present?
  # find_or_create_by! looks up the user by email first so re-running `db:seed` doesn't
  # error out on a duplicate; update! then makes sure the password always matches ENV,
  # in case ADMIN_PASSWORD was rotated.
  user = User.find_or_create_by!(email_address: admin_email) do |u|
    u.password = admin_password
  end
  user.update!(password: admin_password) unless user.authenticate(admin_password)
  puts "Seeded login user: #{user.email_address}"
end

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
