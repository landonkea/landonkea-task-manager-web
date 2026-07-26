# `require_relative "boot"` loads the boot.rb file (in the same folder).
# boot.rb sets up Bundler so Ruby knows where to find all your gems/libraries.
# This MUST come first, before anything else, so the gem system is ready.
require_relative "boot"

# `require "rails/all"` loads the entire Rails framework in one line.
# This gives you Active Record (database), Action Controller (web requests),
# Action Mailer (emails), Action Cable (real-time), and everything else Rails offers.
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

# `Bundler.require(*Rails.groups)` tells Bundler to automatically load all gems
# from your Gemfile that belong to the current environment (development, test, or production).
# `*Rails.groups` expands to something like `[:default, :development]` depending on your ENV.
# This means you don't have to manually `require` each gem -- Rails does it for you.
Bundler.require(*Rails.groups)

# `module TaskManagerWeb` creates a namespace (a container) for your app's code.
# This prevents naming conflicts with other libraries. Your app's code lives inside this module.
module TaskManagerWeb
  # `class Application < Rails::Application` defines your main app class.
  # It inherits from Rails::Application, which gives it all the power of Rails.
  # This is the central object that Rails uses to run your app.
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.

    # `config.load_defaults 8.1` sets all the default Rails 8.1 settings at once.
    # This controls things like how cookies work, how forms behave, and more.
    # Instead of configuring 50+ things individually, this one line sets them all to
    # the recommended defaults for Rails 8.1.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.

    # `config.autoload_lib(ignore: %w[assets tasks])` tells Rails to automatically load
    # Ruby files from the `lib/` folder, EXCEPT for the `assets` and `tasks` subfolders.
    # Autoloading means Rails will find and load Ruby files on-demand as they're needed,
    # instead of loading everything at startup (which would be slower).
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    # The lines above are commented out examples. You can uncomment them to:
    #   - Set your app's default time zone
    #   - Add extra folders to Rails' autoload search path
  end
end
