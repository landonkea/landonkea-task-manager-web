# This file loads and starts your entire Rails application.
# It's the final step in the boot process -- by the time this file finishes,
# your app is fully loaded and ready to receive web requests.

# Load the Rails application.

# `require_relative "application"` loads your application.rb file (from this same folder).
# application.rb defines your app's settings and configuration.
# This must happen first before we can initialize the app.
require_relative "application"

# Initialize the Rails application.

# `Rails.application.initialize!` actually starts up your Rails app.
# The `!` (bang) means this is the final, irreversible initialization step.
# During initialization, Rails reads your environment configs, sets up the database,
# loads routes, and does dozens of other setup tasks behind the scenes.
# Once this line runs, your app is live and ready to handle HTTP requests.
Rails.application.initialize!
