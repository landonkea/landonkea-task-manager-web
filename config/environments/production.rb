# This file contains settings specifically for the PRODUCTION environment.
# Production is when your app is live and serving real users on the internet.
# Settings here OVERRIDE the general settings in application.rb.

# `require "active_support/core_ext/integer/time"` loads Rails helper methods
# that let you write human-readable time durations like `2.days`, `1.year`, etc.
require "active_support/core_ext/integer/time"

# `Rails.application.configure do` starts the block where you set production-specific config.
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.

  # `config.enable_reloading = false` disables automatic code reloading in production.
  # This is a performance optimization: Rails doesn't check for file changes between requests.
  # In production, you deploy code by restarting the server, not by editing files live.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).

  # `config.eager_load = true` loads ALL your Ruby code when the server starts.
  # This trades slower startup time for faster request handling, because Rails doesn't
  # have to find and load files on-demand during each request. Better for production.
  config.eager_load = true

  # Full error reports are disabled.

  # `config.consider_all_requests_local = false` hides detailed error information from users.
  # Instead of showing a stack trace (which would reveal your code structure to attackers),
  # users see a generic "Something went wrong" page. Check your logs for the real errors.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.

  # `config.action_controller.perform_caching = true` enables caching in production.
  # Caching stores pre-rendered HTML fragments so pages load much faster.
  # This is critical for handling real traffic efficiently.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.

  # `config.public_file_server.headers` tells browsers to cache static files (JS, CSS, images)
  # for 1 year. This is safe because Rails adds a "fingerprint" hash to filenames when they change,
  # so browsers automatically fetch the new version when you deploy an update.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"
  # The commented-out line above would let you serve static assets from a separate server or CDN
  # (like CloudFront), which can be faster than serving them from your Rails server.

  # Store uploaded files on the local file system (see config/storage.yml for options).

  # `config.active_storage.service = :local` saves uploaded files to the local disk.
  # For high-traffic apps, you'd change this to `:amazon` or another cloud service.
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # config.assume_ssl = true
  # The commented-out line above tells Rails to trust the X-Forwarded-Proto header from
  # your proxy (like Nginx or a load balancer). Use this when SSL is terminated at the proxy.

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true
  # The commented-out line above would redirect all HTTP requests to HTTPS and set security
  # headers. Essential for protecting user data in production. Uncomment when ready for HTTPS.

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }
  # The commented-out line above would exclude the /up health check URL from HTTPS redirects,
  # which is useful when load balancers check health over plain HTTP.

  # Log to STDOUT with the current request id as a default log tag.

  # `config.log_tags = [ :request_id ]` adds a unique request ID to every log line.
  # This lets you trace all log entries for a single web request, even when many requests
  # are happening simultaneously.
  config.log_tags = [ :request_id ]
  # `config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)` sends logs to standard output
  # (STDOUT). In production, container orchestrators (like Docker/Kamal) capture STDOUT
  # for centralized log collection and monitoring.
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).

  # `config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")` sets how much detail to log.
  # "info" logs normal operations. "debug" logs everything (verbose, not for production).
  # Read from environment variable so you can change it without redeploying code.
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.

  # `config.silence_healthcheck_path = "/up"` stops logging requests to the /up health check.
  # Load balancers ping /up every few seconds. Without this, your logs would be full of
  # health check entries, drowning out important application logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.

  # `config.active_support.report_deprecations = false` suppresses deprecation warnings in production.
  # Deprecations are noisy and don't help end users. You'd check for them during development instead.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.

  # `config.cache_store = :solid_cache_store` uses Solid Cache, which stores cached data
  # in a database instead of memory. This means the cache survives server restarts and
  # works across multiple server processes, making it production-ready.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.

  # `config.active_job.queue_adapter = :solid_queue` tells Active Job to use Solid Queue
  # for background jobs. Solid Queue stores jobs in a database, so they survive restarts
  # and can be processed by multiple worker processes.
  config.active_job.queue_adapter = :solid_queue
  # `config.solid_queue.connects_to` tells Solid Queue to use the dedicated "queue" database
  # connection defined in database.yml, keeping job data separate from your main app data.
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false
  # The commented-out line above would suppress email delivery errors.
  # The default in production is `true` (raise errors) so you know about email problems.

  # Set host to be used by links generated in mailer templates.

  # `config.action_mailer.default_url_options` sets the hostname for links in emails.
  # In production, this should be your real domain name (like your-app.com).
  # Currently set to "example.com" -- change this before going live!
  config.action_mailer.default_url_options = { host: "example.com" }

  # Specify outgoing SMTP server. Remember to add smtp/* credentials via bin/rails credentials:edit.
  # config.action_mailer.smtp_settings = {
  #   user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #   password: Rails.application.credentials.dig(:smtp, :password),
  #   address: "smtp.example.com",
  #   port: 587,
  #   authentication: :plain
  # }
  # The commented-out section above configures an SMTP email server for sending real emails.
  # You'd uncomment and fill this in with your email provider's settings (like SendGrid, Mailgun).

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).

  # `config.i18n.fallbacks = true` makes your app fall back to English when a translation
  # is missing in the user's language. Without this, missing translations would cause errors.
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.

  # `config.active_record.dump_schema_after_migration = false` prevents Rails from automatically
  # updating `schema.rb` after running migrations in production. This avoids accidental changes
  # to your schema file during production maintenance.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.

  # `config.active_record.attributes_for_inspect = [ :id ]` limits what data is shown
  # when you inspect an ActiveRecord object (like in a console). Only the ID is shown,
  # preventing accidental exposure of sensitive data in logs or console output.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # The commented-out lines above restrict which hostnames your app will respond to.
  # This prevents DNS rebinding attacks where an attacker tricks your server into
  # serving malicious content. Set this to your actual domain before going live.

  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
  # The commented-out line above would exempt the /up health check from host protection,
  # so load balancers can check your app's health without being blocked.
end
