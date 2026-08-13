# This file contains settings for the DEV environment.
#
# Don't confuse this with config/environments/development.rb - that one is for running
# the app on your own machine with `bin/dev`. This one, "dev", is a deployed environment:
# a real (if placeholder-hosted, see config/deploy.dev.yml) Kamal destination that runs
# the same production-style Docker image as staging and production, just earlier in the
# pipeline. Code usually lands here first, gets poked at, then moves on to staging.
#
# This file mirrors config/environments/staging.rb, which itself mirrors production.rb.
# The one deliberate difference from staging: full error pages stay on, because dev is
# where you're actively chasing down a bug in a freshly deployed build, not verifying
# a near-final one.

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Same as staging/production: the Docker image doesn't support live reloading, and
  # eager loading here catches boot-time errors before they'd surface in staging.
  config.enable_reloading = false
  config.eager_load = true

  # Unlike staging/production: show full error pages with backtraces. Dev is where
  # you're debugging a build that just landed, so a stack trace in the browser saves
  # a trip to the logs. This is safe because dev is never meant to hold real user data.
  config.consider_all_requests_local = true

  # Same as staging/production: exercise fragment caching so dev reflects real behavior.
  config.action_controller.perform_caching = true

  # Same as staging/production: cache fingerprinted assets for a year.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Same as staging/production: serve uploads from local disk.
  config.active_storage.service = :local

  # Same as staging/production: log to STDOUT with request IDs for Kamal/Docker log collection.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Default to "debug" like staging - dev is the noisiest environment on purpose, since
  # it exists to make new code easy to inspect. Still overridable via RAILS_LOG_LEVEL.
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "debug")

  # Same as staging/production: don't let /up health checks flood the logs.
  config.silence_healthcheck_path = "/up"

  # Same as staging/production: deprecation noise isn't useful here either.
  config.active_support.report_deprecations = false

  # Same as staging/production: use the database-backed cache/queue adapters so dev
  # exercises the same Solid Cache / Solid Queue code paths the later environments use.
  # Points at the `dev` environment's own cache/queue databases (config/database.yml),
  # separate SQLite files from both staging and production.
  config.cache_store = :solid_cache_store
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Set host to be used by links generated in mailer templates. Same LAN server as
  # staging/production for now (see config/deploy.dev.yml), overridable via APP_HOST.
  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "192.168.0.1") }

  # Same as staging/production: I18n fallback to default locale rather than raising.
  config.i18n.fallbacks = true

  # Same as staging/production: don't let dev boots rewrite schema.rb.
  config.active_record.dump_schema_after_migration = false

  # Same as staging/production: keep console/log inspection output limited to :id.
  config.active_record.attributes_for_inspect = [ :id ]
end
