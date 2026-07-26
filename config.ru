# This file is the Rack configuration file. Rack is a standard interface that all
# Ruby web servers use to talk to Ruby web apps. This file is how servers like
# Puma, Unicorn, or Passenger know how to start your Rails application.

# This file is used by Rack-based servers to start the application.

# `require_relative "config/environment"` loads your entire Rails application.
# This triggers the full boot process: loading gems, reading configs, setting up routes,
# and initializing the database connection. After this line, your app is fully loaded.
require_relative "config/environment"

# `run Rails.application` tells Rack to use your Rails app to handle incoming requests.
# `Rails.application` is the central object (defined in application.rb) that knows
# how to route requests to the right controllers and render responses.
run Rails.application

# `Rails.application.load_server` tells Rails to load any server-specific configurations.
# This ensures that middleware and other server components are properly initialized.
# It's the final step that makes your app ready to accept web traffic.
Rails.application.load_server
