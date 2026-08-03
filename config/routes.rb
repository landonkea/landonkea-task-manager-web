# This file tells Rails which web pages (URLs) your app responds to.
# Think of it like a phone directory: "when someone visits /tasks, show them this page."

# `Rails.application.routes.draw do` starts the block where you define all your URLs.
# Everything between `do` and `end` is a route definition.
Rails.application.routes.draw do
  # `resource :session` (singular) creates the login/logout URLs backed by SessionsController:
  #   GET    /session/new -> show the sign-in form (new action)
  #   POST   /session     -> sign in with email/password (create action)
  #   DELETE /session     -> sign out (destroy action)
  # There is deliberately no "resources :users" / signup route here - this is a minimal,
  # single-user auth gate (see db/seeds.rb), not a full multi-user product with registration.
  resource :session

  # `resources :tasks` automatically creates ALL the standard URLs for managing tasks:
  #   GET    /tasks        -> list all tasks        (index action)
  #   GET    /tasks/new    -> show a form for a new task (new action)
  #   POST   /tasks        -> create a new task      (create action)
  #   GET    /tasks/:id    -> show one specific task  (show action)
  #   GET    /tasks/:id/edit -> show a form to edit  (edit action)
  #   PATCH  /tasks/:id    -> update an existing task (update action)
  #   DELETE /tasks/:id    -> delete a task           (destroy action)
  # This one line saves you from writing 7 separate route definitions!
  resources :tasks

  # `get "up"` creates a URL at /up that checks if your app is healthy and running.
  # It points to the built-in Rails health check controller at `rails/health#show`.
  # `as: :rails_health_check` gives this route a shortcut name so you can use
  # `rails_health_check_path` in code instead of hardcoding "/up".
  get "up" => "rails/health#show", as: :rails_health_check

  # `root` sets the homepage. When someone visits just "/", they see the tasks index page.
  # This is the first page users see when they open your app in a browser.
  root "tasks#index"
end
