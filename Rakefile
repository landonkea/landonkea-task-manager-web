# This file is the entry point for Rake, Ruby's built-in task runner.
# Rake lets you run command-line tasks (like database migrations or test suites)
# by typing `rake task_name` in your terminal.

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# `require_relative "config/application"` loads your entire Rails application.
# This is necessary because most Rake tasks need access to your app's code,
# database connection, and configuration to do their work.
require_relative "config/application"

# `Rails.application.load_tasks` tells Rails to register all of its built-in Rake tasks.
# This includes tasks like `db:migrate`, `db:seed`, `test`, `routes`, and dozens more.
# After this line, you can run `bin/rails <task_name>` or `rake <task_name>` from the terminal.
Rails.application.load_tasks
