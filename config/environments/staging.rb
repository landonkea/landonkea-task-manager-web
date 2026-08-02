# This file contains settings for the STAGING environment.
# Staging is a production-like environment used to verify a deploy before it reaches
# production. It runs on the same LAN server as production (192.168.0.1) but as a
# separate Kamal service/container with its own port, volume, and SQLite database files
# (see config/deploy.staging.yml and the `staging:` section of config/database.yml).
#
# Rails has no built-in way to "alias" one environment's settings onto another --
# each environment needs its own file under config/environments. This file intentionally
# mirrors config/environments/production.rb line-for-line except where staging needs to
# behave differently (noted inline below), so staging stays a faithful rehearsal of prod.

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Same as production: no reloading, eager load everything. Staging exists to catch
  # the exact boot/eager-load behavior production will have, so we don't want the
  # more forgiving development-style settings here.
  config.enable_reloading = false
  config.eager_load = true

  # Same as production: hide detailed error pages from anyone browsing staging.
  config.consider_all_requests_local = false

  # Same as production: exercise fragment caching so staging reflects real caching behavior.
  config.action_controller.perform_caching = true

  # Same as production: cache fingerprinted assets for a year.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Same as production: serve uploads from local disk.
  config.active_storage.service = :local

  # Same as production: log to STDOUT with request IDs so Kamal/Docker log collection works.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Same as production, but default to "debug" here rather than "info" -- staging is
  # where you're actively poking at a pre-release build, so more verbose logs by
  # default are more useful than they'd be in production. Still overridable via ENV.
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "debug")

  # Same as production: don't let /up health checks flood the logs.
  config.silence_healthcheck_path = "/up"

  # Same as production: deprecation noise isn't useful here either.
  config.active_support.report_deprecations = false

  # Same as production: use the database-backed cache/queue adapters so staging
  # exercises the same Solid Cache / Solid Queue code paths production uses.
  # Each points at the `staging` environment's own `cache`/`queue` databases
  # (config/database.yml), which are separate SQLite files from production's.
  config.cache_store = :solid_cache_store
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Set host to be used by links generated in mailer templates.
  # Same LAN server as production, but staging runs as a distinct Kamal service on its
  # own port (see config/deploy.staging.yml), so APP_HOST should be set to include that
  # port when staging is deployed. Defaults to the bare LAN IP for local verification.
  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "192.168.0.1") }

  # Same as production: I18n fallback to default locale rather than raising.
  config.i18n.fallbacks = true

  # Same as production: don't let staging boots rewrite schema.rb.
  config.active_record.dump_schema_after_migration = false

  # Same as production: keep console/log inspection output limited to :id.
  config.active_record.attributes_for_inspect = [ :id ]
end
