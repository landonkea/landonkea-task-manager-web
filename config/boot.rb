# This file runs BEFORE anything else in your Rails app.
# Its job is to set up the gem (library) loading system so all your other code can use gems.

# `ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)`
# This tells Bundler where your Gemfile is located.
# `ENV["BUNDLE_GEMFILE"]` reads an environment variable (a system-level setting).
# `||=` means "only set this if it's not already set" (useful if someone configured it manually).
# `File.expand_path("../Gemfile", __dir__)` builds the full path to your Gemfile,
# going up one directory from this file's location (since this file is in config/).
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

# `require "bundler/setup"` loads Bundler and tells it to make all your gems available.
# This reads your Gemfile and sets up the correct versions of each gem your app needs.
# Without this line, Ruby wouldn't know where to find Rails, or any other gem.
require "bundler/setup" # Set up gems listed in the Gemfile.

# `require "bootsnap/setup"` loads the Bootsnap gem, which dramatically speeds up
# your app's boot time. It does this by caching expensive operations like:
#   - Finding and loading Ruby files (autocomplete/index caching)
#   - Compiling Ruby code (YAML/JSON parsing caching)
# This can cut startup time by 50% or more.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
