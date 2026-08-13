# Set the Rails environment variable to "test" if it isn't already set.
# This tells Rails to use the test configuration (database, settings, etc.)
# The ||= operator means "assign only if currently nil/undefined."
# This is important because tests should never run against your real/production data.
ENV["RAILS_ENV"] ||= "test"

# Load the full Rails application by requiring the environment config file.
# This boots up the app so that all models, controllers, and settings are available
# in your tests, just like they would be when the real app is running.
require_relative "../config/environment"

# Load Rails' built-in test helpers, which provide useful methods like
# assert, assert_equal, etc. These make writing tests much easier.
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

# Open the ActiveSupport module and define a base TestCase class inside it.
# This is where you put setup code and helpers that ALL your tests will share.
# By defining it here, every test file automatically inherits this behavior.
module ActiveSupport
  class TestCase
    # Run tests in parallel with the number of CPU cores on your machine.
    # This makes the test suite run much faster by testing multiple files at once.
    # "workers: :number_of_processors" automatically picks the right number.
    parallelize(workers: :number_of_processors)

    # Automatically load every .yml file in the test/fixtures/ folder.
    # These are fake data records (like sample tasks) that tests can use
    # instead of creating everything from scratch. The "all" means load every fixture.
    fixtures :all

    # This is a placeholder comment. You can add your own custom helper methods
    # here that you want available in every single test file in the project.
  end
end
