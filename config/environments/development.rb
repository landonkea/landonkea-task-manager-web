# This file contains settings specifically for the DEVELOPMENT environment.
# Development is when you're actively building and testing your app on your own computer.
# Settings here OVERRIDE the general settings in application.rb.

# `require "active_support/core_ext/integer/time"` loads Rails helper methods
# that let you write human-readable time durations like `2.days`, `5.minutes`, etc.
# Without this, you'd have to calculate raw seconds manually.
require "active_support/core_ext/integer/time"

# `Rails.application.configure do` starts the block where you set development-specific config.
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Make code changes take effect immediately without server restart.

  # `config.enable_reloading = true` tells Rails to automatically reload code when you change files.
  # So when you edit a controller or model, you don't need to restart the server -- changes take effect
  # immediately. This makes development much faster. Set to `false` in production for speed.
  config.enable_reloading = true

  # Do not eager load code on boot.

  # `config.eager_load = false` means Rails loads code on-demand (lazily) during development.
  # It only loads Ruby files when they're actually needed, which makes the server start faster.
  # In production, this is `true` so all code is loaded upfront for better request performance.
  config.eager_load = false

  # Show full error reports.

  # `config.consider_all_requests_local = true` shows detailed error pages in the browser
  # when something goes wrong. You'll see a full stack trace, the exact line that failed,
  # and the values of all variables. Essential for debugging during development.
  config.consider_all_requests_local = true

  # Enable server timing.

  # `config.server_timing = true` adds timing headers to responses so you can see
  # in your browser's developer tools exactly how long each part of the request took
  # (database queries, view rendering, etc.). Great for performance debugging.
  config.server_timing = true

  # Enable/disable Action Controller caching. By default Action Controller caching is disabled.
  # Run rails dev:cache to toggle Action Controller caching.

  # This `if` block checks whether a special file exists (`tmp/caching-dev.txt`).
  # You create this file by running `rails dev:cache` to toggle caching on/off in development.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    # `perform_caching = true` turns on page/fragment caching for development.
    config.action_controller.perform_caching = true
    # `enable_fragment_cache_logging = true` logs when fragments are cached or served from cache.
    config.action_controller.enable_fragment_cache_logging = true
    # Sets public files to be cached by browsers for 2 days in development when caching is on.
    config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }
  else
    # `perform_caching = false` disables caching during development (the default).
    # This means every request hits the database/rendering pipeline, which is better
    # for seeing your changes reflected immediately.
    config.action_controller.perform_caching = false
  end

  # Change to :null_store to avoid any caching.

  # `config.cache_store = :memory_store` uses RAM for caching.
  # This is fast and simple for development but doesn't persist across server restarts.
  # `:null_store` would disable caching entirely; `:memory_store` at least tests that
  # your caching code works correctly.
  config.cache_store = :memory_store

  # Store uploaded files on the local file system (see config/storage.yml for options).

  # `config.active_storage.service = :local` tells Active Storage to save uploaded files
  # to your local hard drive (in the `storage/` folder) instead of cloud storage.
  config.active_storage.service = :local

  # Don't care if the mailer can't send.

  # `config.action_mailer.raise_delivery_errors = false` suppresses errors when emails fail to send.
  # During development you usually don't have a real email server configured,
  # so this prevents noisy error messages every time a mailer is triggered.
  config.action_mailer.raise_delivery_errors = false

  # Make template changes take effect immediately.

  # `config.action_mailer.perform_caching = false` disables caching of mailer templates.
  # This means if you change an email template, you see the change immediately without restart.
  config.action_mailer.perform_caching = false

  # Set localhost to be used by links generated in mailer templates.

  # `config.action_mailer.default_url_options` sets the base URL used in email links.
  # When your app generates links in emails (like "Click here to reset your password"),
  # it needs to know the hostname and port. In development, your app runs at localhost:3000.
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # Print deprecation notices to the Rails logger.

  # `config.active_support.deprecation = :log` writes deprecation warnings to your log file.
  # Deprecations are warnings about code that will be removed in future Rails versions.
  # Logging them helps you stay up-to-date without breaking your app.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.

  # `config.active_record.migration_error = :page_load` shows an error page if you visit
  # your app but haven't run pending database migrations yet. This prevents confusing errors
  # caused by your database schema being out of date with your code.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.

  # `config.active_record.verbose_query_logs = true` adds helpful context to SQL queries in your log.
  # It shows the exact line of Ruby code (controller action, model method) that triggered each query.
  # This makes it much easier to find and optimize slow or unnecessary database calls.
  config.active_record.verbose_query_logs = true

  # Append comments with runtime information tags to SQL queries in logs.

  # `config.active_record.query_log_tags_enabled = true` adds metadata tags as SQL comments
  # to each database query, like which controller action or job triggered it.
  # These tags show up in your database's slow query log, helping you trace performance issues.
  config.active_record.query_log_tags_enabled = true

  # Highlight code that enqueued background job in logs.

  # `config.active_job.verbose_enqueue_logs = true` logs which line of code triggered
  # each background job to be queued. This helps you track down what's creating jobs.
  config.active_job.verbose_enqueue_logs = true

  # Highlight code that triggered redirect in logs.

  # `config.action_dispatch.verbose_redirect_logs = true` logs detailed info about HTTP redirects,
  # including which line of code caused the redirect. Useful for debugging redirect loops.
  config.action_dispatch.verbose_redirect_logs = true

  # Suppress logger output for asset requests.

  # `config.assets.quiet = true` silences the log messages from asset requests (CSS, JS, images).
  # Without this, your development log would be flooded with entries for every stylesheet and
  # script file the browser requests, making it harder to find the important log entries.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true
  # The commented-out line above would make your app crash if a translation key is missing.
  # Useful for catching typos in locale files, but annoying during everyday development.

  # Annotate rendered view with file names.

  # `config.action_view.annotate_rendered_view_with_filenames = true` adds HTML comments
  # in your browser showing which partial/template file rendered each section of the page.
  # Inspect your page in browser DevTools and you'll see comments like `<!-- app/views/tasks/_form.html.erb -->`.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true
  # The commented-out line above would let any website connect to your WebSockets.
  # Only use this for development/debugging -- it's a security risk in production.

  # Raise error when a before_action's only/except options reference missing actions.

  # `config.action_controller.raise_on_missing_callback_actions = true` crashes your app
  # with a clear error message if a before_action (before_filter) references an action that
  # doesn't exist. This catches typos like `before_action :authenticate, only: [:showww]`
  # early, instead of silently failing.
  config.action_controller.raise_on_missing_callback_actions = true

  # Apply autocorrection by RuboCop to files generated by `bin/rails generate`.
  # config.generators.apply_rubocop_autocorrect_after_generate!
  # The commented-out line above would auto-format code created by Rails generators
  # using RuboCop (a Ruby style checker). Handy for keeping generated code consistent.

  # Detect N+1 queries and unused eager loading with Bullet [https://github.com/flyerhzm/bullet]

  # Bullet watches ActiveRecord queries during development and warns you when it spots
  # an N+1 query or eager loading that wasn't actually used. This config follows Bullet's
  # own recommended setup: log warnings to the Rails log and Bullet's own log file, pop up
  # a browser alert, and print to the browser console for quick visibility while developing.
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  end
end
