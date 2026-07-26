# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

# This file contains settings specifically for the TEST environment.
# Tests are automated checks that verify your code works correctly.
# Settings here OVERRIDE the general settings in application.rb.

# `Rails.application.configure do` starts the block where you set test-specific config.
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.

  # `config.enable_reloading = false` disables code reloading during tests.
  # Tests don't modify source files, so checking for changes would waste time.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.

  # `config.eager_load = ENV["CI"].present?` enables eager loading ONLY in CI (continuous integration).
  # When running tests on GitHub Actions or similar, eager loading catches errors where
  # files reference classes that can't be found at boot time. Locally it's off for speed.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with cache-control for performance.

  # `config.public_file_server.headers` tells the test server to set cache headers on static files.
  # This simulates how production serves assets, ensuring your tests accurately reflect
  # real-world behavior. `max-age=3600` means cache for 1 hour.
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Show full error reports.

  # `config.consider_all_requests_local = true` shows detailed error pages during tests,
  # making it easier to debug test failures.
  config.consider_all_requests_local = true

  # `config.cache_store = :null_store` disables caching during tests entirely.
  # `:null_store` throws away everything that's "cached" -- this ensures tests are
  # predictable and not affected by stale cached data from previous test runs.
  config.cache_store = :null_store

  # Render exception templates for rescuable exceptions and raise for other exceptions.

  # `config.action_dispatch.show_exceptions = :rescuable` renders error pages for exceptions
  # that your app knows how to handle (like 404 Not Found), but raises errors for unexpected
  # exceptions so your test suite catches real bugs.
  config.action_dispatch.show_exceptions = :rescuable

  # Disable request forgery protection in test environment.

  # `config.action_controller.allow_forgery_protection = false` disables CSRF (Cross-Site Request
  # Forgery) protection during tests. CSRF protection requires special tokens in forms, and
  # disabling it makes tests simpler because you don't have to include those tokens in test requests.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.

  # `config.active_storage.service = :test` uses the test storage configuration from storage.yml.
  # Files uploaded during tests go to `tmp/storage` and are cleaned up between test runs.
  config.active_storage.service = :test

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.

  # `config.action_mailer.delivery_method = :test` intercepts outgoing emails instead of
  # actually sending them. Emails are collected in `ActionMailer::Base.deliveries` so your
  # tests can verify that the right email was sent with the right content.
  config.action_mailer.delivery_method = :test

  # Set host to be used by links generated in mailer templates.

  # `config.action_mailer.default_url_options` sets the base URL for email links during tests.
  # Uses "example.com" as a placeholder since tests don't need real URLs.
  config.action_mailer.default_url_options = { host: "example.com" }

  # Print deprecation notices to the stderr.

  # `config.active_support.deprecation = :stderr` sends deprecation warnings to STDERR
  # during tests instead of the log. This makes them more visible in test output
  # so you notice them while running your test suite.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true
  # The commented-out line above would make tests fail if a translation key is missing,
  # which is useful for catching locale file bugs. Disabled by default to reduce noise.

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true
  # The commented-out line above would add HTML comments showing which template rendered
  # each part of the page. Useful for debugging but not needed in test output.

  # Raise error when a before_action's only/except options reference missing actions.

  # `config.action_controller.raise_on_missing_callback_actions = true` makes tests fail
  # with a clear error if a before_action references an action that doesn't exist.
  # This catches typos like `before_action :authenticate, only: [:showww]` early.
  config.action_controller.raise_on_missing_callback_actions = true
end
