require "test_helper"

# Base class every system test (browser-driven, end-to-end test) would
# inherit from. Rails' own generator scaffolds this file by default for
# every new app — it was missing here, which meant the "system-test" CI
# job's `bin/rails db:test:prepare test:system` command errored outright
# (LoadError: cannot load such file -- test/system) since Rails' test
# runner expects this conventional file to exist even before any actual
# system test files are written. With this file present, the task runs
# successfully and reports zero tests until real system tests are added.
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
end
