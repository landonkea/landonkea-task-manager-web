# This rake task runs the test suite and RuboCop, then writes a single
# human-readable summary to test-results/latest.md. It's meant to give
# a persisted, at-a-glance snapshot of "are tests green / is lint clean"
# without having to scroll back through raw command output -- handy
# locally and as a CI artifact (see .github/workflows/ci.yml).
#
# Usage:
#   bin/rails test_report
#
# The generated report (test-results/latest.md) is intentionally
# gitignored -- it's a build artifact, regenerated on every run, not
# something to track in version control.

require "fileutils"
require "open3"
require "time"

# Namespaced helper module so we don't leak generically-named methods
# (summarize, render, etc.) onto the global rake context.
module TestReport
  module_function

  # Pulls the pass/fail/error/skip counts and the list of failing tests out
  # of Minitest's plain-text output. Minitest's summary line looks like:
  #   12 runs, 20 assertions, 1 failures, 0 errors, 0 skips
  def summarize_minitest(output)
    counts = { runs: 0, assertions: 0, failures: 0, errors: 0, skips: 0 }

    if (match = output.match(/(\d+) runs, (\d+) assertions, (\d+) failures, (\d+) errors, (\d+) skips/))
      counts[:runs] = match[1].to_i
      counts[:assertions] = match[2].to_i
      counts[:failures] = match[3].to_i
      counts[:errors] = match[4].to_i
      counts[:skips] = match[5].to_i
    end

    # Failure/error blocks in Minitest output look like:
    #   Failure:
    #   TaskTest#test_something [test/models/task_test.rb:12]:
    #   <failure message>
    # (older/other Minitest formats prefix this with "1) "). Either way, the
    # line right after "Failure:"/"Error:" identifies the failing test.
    failures = output.scan(/^\s*(?:\d+\)\s+)?(?:Failure|Error):\n(.+)$/).flatten.map(&:strip)

    { counts: counts, failures: failures }
  end

  # Pulls the offense count out of RuboCop's plain-text summary line, e.g.
  #   123 files inspected, 2 offenses detected
  # RuboCop says "no offenses detected" (not "0 offenses") when clean, so
  # that's matched as a special case.
  def summarize_rubocop(output)
    files_inspected = nil
    offenses = nil

    if (match = output.match(/(\d+) files? inspected, (no|\d+) offenses? detected/))
      files_inspected = match[1].to_i
      offenses = match[2] == "no" ? 0 : match[2].to_i
    end

    { files_inspected: files_inspected, offenses: offenses }
  end

  def render(timestamp:, test_status:, test_summary:, test_stdout:, rubocop_status:, rubocop_summary:, rubocop_stdout:)
    counts = test_summary[:counts]
    failures = test_summary[:failures]

    <<~MARKDOWN
      # Test Report

      Generated: #{timestamp.utc.iso8601}

      ## Summary

      | Check | Result |
      |-------|--------|
      | `bin/rails test` | #{test_status.success? ? "PASS" : "FAIL"} (#{counts[:runs]} runs, #{counts[:assertions]} assertions, #{counts[:failures]} failures, #{counts[:errors]} errors, #{counts[:skips]} skips) |
      | `bin/rubocop` | #{rubocop_status.success? ? "PASS" : "FAIL"} (#{rubocop_summary[:offenses] || "?"} offenses across #{rubocop_summary[:files_inspected] || "?"} files) |

      ## Test Failures

      #{failures.empty? ? "None." : failures.map { |f| "- #{f}" }.join("\n")}

      ## RuboCop Offenses

      #{rubocop_summary[:offenses].to_i.zero? ? "None." : "#{rubocop_summary[:offenses]} offense(s) detected. See raw output below."}

      <details>
      <summary>Raw `bin/rails test` output</summary>

      ```
      #{test_stdout.strip}
      ```

      </details>

      <details>
      <summary>Raw `bin/rubocop` output</summary>

      ```
      #{rubocop_stdout.strip}
      ```

      </details>
    MARKDOWN
  end
end

namespace :test_report do
  desc "Run bin/rails test and bin/rubocop, writing a summary to test-results/latest.md"
  task generate: :environment do
    report_dir = Rails.root.join("test-results")
    FileUtils.mkdir_p(report_dir)
    report_path = report_dir.join("latest.md")

    puts "==> Running bin/rails test..."
    test_stdout, test_status = Open3.capture2e(
      { "RAILS_ENV" => "test" },
      Rails.root.join("bin/rails").to_s, "test",
      chdir: Rails.root.to_s
    )

    puts "==> Running bin/rubocop..."
    rubocop_stdout, rubocop_status = Open3.capture2e(
      Rails.root.join("bin/rubocop").to_s,
      chdir: Rails.root.to_s
    )

    test_summary = TestReport.summarize_minitest(test_stdout)
    rubocop_summary = TestReport.summarize_rubocop(rubocop_stdout)

    File.write(report_path, TestReport.render(
      timestamp: Time.now,
      test_status: test_status,
      test_summary: test_summary,
      test_stdout: test_stdout,
      rubocop_status: rubocop_status,
      rubocop_summary: rubocop_summary,
      rubocop_stdout: rubocop_stdout
    ))

    puts "==> Report written to #{report_path}"

    # Exit non-zero if either check failed, so this task can gate CI if desired.
    exit(1) unless test_status.success? && rubocop_status.success?
  end
end

desc "Run tests and RuboCop, writing a summary report to test-results/latest.md"
task test_report: "test_report:generate"
