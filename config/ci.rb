# This file defines your CI (Continuous Integration) pipeline.
# CI automatically runs checks on your code every time you push changes,
# catching bugs and style issues before they reach production.

# Run using bin/ci

# `CI.run do` starts the CI pipeline. It will run each step in order.
# If any step fails, the pipeline stops and reports the failure.
CI.run do
  # `step "Setup", "bin/setup --skip-server"` runs your app's setup script
  # to ensure dependencies are installed and the database is ready.
  # `--skip-server` skips starting the web server since we only need the environment.
  step "Setup", "bin/setup --skip-server"

  # `step "Style: Ruby", "bin/rubocop"` runs RuboCop, a tool that checks your Ruby code
  # for style violations and common mistakes. It ensures consistent code formatting
  # across your team, like indentation, naming conventions, and line length.
  step "Style: Ruby", "bin/rubocop"

  # `step "Security: Gem audit", "bin/bundler-audit"` checks your gems (libraries)
  # against a database of known security vulnerabilities. If any gem has a known
  # security issue, this step will fail so you can update to a patched version.
  step "Security: Gem audit", "bin/bundler-audit"

  # `step "Security: Importmap vulnerability audit", "bin/importmap audit"` checks your
  # JavaScript packages (managed by Importmap) for known security vulnerabilities,
  # similar to what bundler-audit does for Ruby gems.
  step "Security: Importmap vulnerability audit", "bin/importmap audit"

  # `step "Security: Brakeman code analysis", "bin/brakeman ..."` runs Brakeman,
  # a static analysis tool that scans your Rails code for security vulnerabilities
  # like SQL injection, XSS, and mass assignment issues. `--quiet` suppresses
  # informational output, `--no-pager` prevents interactive prompts, and the
  # `--exit-on-warn`/`--exit-on-error` flags make it fail the build on findings.
  step "Security: Brakeman code analysis", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"

  # `step "Tests: Rails", "bin/rails test"` runs your entire test suite.
  # This executes all the automated tests that verify your app's features work correctly.
  # If any test fails, the CI pipeline fails, preventing broken code from being deployed.
  step "Tests: Rails", "bin/rails test"

  # `step "Tests: Seeds", "env RAILS_ENV=test bin/rails db:seed:replant"` tests that your
  # seed data (initial data loaded into the database) works correctly in the test environment.
  # `db:seed:replant` clears all data and re-runs seeds, ensuring they're idempotent.
  step "Tests: Seeds", "env RAILS_ENV=test bin/rails db:seed:replant"

  # Optional: Run system tests
  # step "Tests: System", "bin/rails test:system"
  # The commented-out line above would run system tests, which use a real browser
  # to test your app's full user experience. They're slower but test JavaScript
  # interactivity and complete user workflows.

  # Optional: set a green GitHub commit status to unblock PR merge.
  # Requires the `gh` CLI and `gh extension install basecamp/gh-signoff`.
  # if success?
  #   step "Signoff: All systems go. Ready for merge and deploy.", "gh signoff"
  # else
  #   failure "Signoff: CI failed. Do not merge or deploy.", "Fix the issues and try again."
  # end
  # The commented-out section above would mark your GitHub commit as "signed off"
  # when all CI steps pass, which you can configure as a required check before merging PRs.
end
