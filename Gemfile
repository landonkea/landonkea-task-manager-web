# The Gemfile tells Bundler (Ruby's package manager) which gems (libraries) your app needs.
# Bundler reads this file, downloads the listed gems, and makes them available to your app.
# This file is read by running `bundle install` in the terminal.

# "source" tells Bundler where to download gems from.
# rubygems.org is the official Ruby gem repository (like npm for JavaScript).
source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"

# Install the Rails framework, version 8.1.3 or newer within the 8.1 series.
# The ~> operator means "compatible with" — it allows patch updates but not major ones.
# Rails is the full web framework that powers this entire application.
gem "rails", "~> 8.1.3"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]

# Propshaft handles serving CSS, JavaScript, and image files to the browser.
# It's a lightweight replacement for the older Sprockets asset pipeline.
gem "propshaft"

# Use sqlite3 as the database for Active Record

# sqlite3 is a simple, file-based database — perfect for development and testing.
# >= 2.1 means version 2.1 or newer. SQLite stores all data in a single file.
gem "sqlite3", ">= 2.1"

# Use the Puma web server [https://github.com/puma/puma]

# Puma is the web server that receives HTTP requests from browsers and sends responses.
# >= 5.0 means version 5.0 or newer. Puma is fast, threaded, and production-ready.
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]

# Importmap lets you use modern JavaScript modules without needing Node.js or Webpack.
# It "maps" import names to actual file paths in your app.
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]

# Turbo makes your app feel like a single-page app (SPA) without writing much JavaScript.
# It intercepts link clicks and form submissions and fetches only the parts that change.
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]

# Stimulus adds behavior to your HTML with small, reusable JavaScript controllers.
# It's for enhancing pages with interactivity (e.g., toggling a checkbox updates the UI).
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]

# Jbuilder lets you define JSON responses for your API endpoints in a clean, readable way.
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]

# bcrypt provides secure password hashing. It's commented out because
# this app doesn't use user authentication yet. Uncomment it when needed.
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem

# tzinfo-data provides timezone information. It's only needed on Windows and JRuby
# because those platforms don't include Ruby's standard timezone data.
# "platforms: %i[ windows jruby ]" means this gem is only loaded on those platforms.
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable

# Solid Cache stores Rails caching data in the database instead of using Redis.
# This simplifies deployment since you don't need a separate caching service.
gem "solid_cache"

# Solid Queue stores background job data in the database instead of using Redis/Sidekiq.
# Jobs are tasks that run in the background (like sending emails after signup).
gem "solid_queue"

# Solid Cable stores Action Cable (WebSocket) data in the database.
# Action Cable powers real-time features like live chat or live updates.
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb

# Bootsnap speeds up your app's startup time by caching expensive computations.
# require: false means don't load it automatically — Rails loads it manually at boot.
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]

# Kamal is a deployment tool that deploys your Rails app as Docker containers.
# It handles SSH, building images, and managing servers. require: false = load manually.
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]

# Thruster sits in front of Puma and adds HTTP caching, compression, and file serving.
# It makes your app faster by compressing responses and caching static files.
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]

# Image Processing provides tools to resize and transform uploaded images.
# It's used by Active Storage when you create image "variants" (e.g., thumbnails).
gem "image_processing", "~> 2.0"

# As of image_processing 2.0, the vips/minimagick backends are no longer bundled
# automatically -- the app must declare its processing backend explicitly. Rails'
# default Active Storage variant_processor is :vips, and (as of Rails 8.1.3.1's Active
# Storage CVE fix) the configured processor's gem is validated eagerly at boot, so a
# missing backend now fails fast instead of only at first variant request.
gem "ruby-vips", "~> 2.0"

# The "group" keyword limits gems to specific environments.
# :development means "only load this gem when running locally."
# :test means "only load this gem when running tests."
group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem

  # The debug gem adds a debugger to your Rails app so you can pause execution
  # and inspect variables. "platforms" limits it to MRI Ruby and Windows (not JRuby).
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)

  # bundler-audit checks your Gemfile.lock for gems with known security vulnerabilities.
  # require: false means we run it manually (e.g., `bundle audit`) rather than loading it.
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]

  # Brakeman scans your app's code for common security issues like SQL injection.
  # "Static analysis" means it reads your code without running it.
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]

  # RuboCop checks your Ruby code for style and formatting issues.
  # rubocop-rails-omakase is Rails' recommended default style guide.
  gem "rubocop-rails-omakase", require: false
end

# Development-only gems — only loaded when running the app locally.
group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]

  # web-console adds an interactive Ruby console to your error pages in development.
  # When your app crashes, you can type Ruby commands in the browser to debug.
  gem "web-console"

  # Detect N+1 queries and unused eager loading [https://github.com/flyerhzm/bullet]

  # Bullet watches your ActiveRecord queries as the app runs and warns you when it
  # spots an N+1 query (querying associations one-by-one instead of eager loading)
  # or eager loading that was never actually used. Development-only performance aid.
  gem "bullet"
end

# Test-only gems — only loaded when running your test suite.
group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]

  # Capybara lets you write tests that simulate a real user clicking and typing
  # in a browser. It drives an actual browser window during tests.
  gem "capybara"

  # Selenium WebDriver controls a real web browser (like Chrome or Firefox)
  # for system tests. Capybara uses it under the hood to interact with the browser.
  gem "selenium-webdriver"
end
