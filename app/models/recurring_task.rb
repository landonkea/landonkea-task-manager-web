# This file defines the RecurringTask model — a *template* that describes how to
# automatically create regular Task rows on a repeating schedule (e.g. "every 1 week").
#
# The RecurringTask itself is never shown as a to-do item; it's the "recipe" that the
# GenerateRecurringTasksJob (app/jobs/generate_recurring_tasks_job.rb) reads on a schedule
# to spawn real Task records, the same way a bill's "recurring payment" setting isn't a
# payment itself but produces one every month.
class RecurringTask < ApplicationRecord
  # Every Task generated from this template records which template made it (see
  # db/migrate/..._add_recurring_task_to_tasks.rb). dependent: :nullify means destroying a
  # RecurringTask does NOT delete the tasks it already generated — it just clears their
  # recurring_task_id, so past to-dos aren't silently wiped out because someone stopped
  # a repeating chore.
  has_many :tasks, dependent: :nullify

  # "enum" turns the integer "interval_unit" column into a named, readable concept.
  # Under the hood the database stores 0/1/2, but in Ruby code you write
  # recurring_task.interval_unit = "weekly" and can call recurring_task.weekly?
  # The order here (daily < weekly < monthly) is arbitrary — unlike Task#priority, there's
  # no "greater than" comparison that depends on it — but keeping it stable matters once
  # real data exists, since the integers are what's actually stored.
  enum :interval_unit, { daily: 0, weekly: 1, monthly: 2 }, validate: true

  # A template needs a name (copied onto every Task it generates) — same rules as Task#name.
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }

  # interval_count is the "1" in "every 1 week". It must be a positive whole number —
  # "every 0 weeks" or "every -2 weeks" don't mean anything.
  validates :interval_count, numericality: { only_integer: true, greater_than: 0 }

  # Every template needs to know when it's next due to fire.
  validates :next_run_on, presence: true

  # This creates a shortcut called "active" that finds all templates the user hasn't
  # paused. Instead of writing RecurringTask.where(active: true) everywhere, you can
  # just write RecurringTask.active.
  scope :active, -> { where(active: true) }

  # This creates a shortcut called "due" that finds all templates whose next_run_on has
  # arrived (today or earlier). ".." would exclude today; "..Date.current" is an endless
  # range up to and including today, so a template scheduled for today fires today.
  scope :due, -> { where(next_run_on: ..Date.current) }

  # This creates a shortcut called "due_for_generation" that combines both of the above:
  # only active templates whose scheduled date has arrived. This is the exact query the
  # generator job runs on every scheduled sweep.
  scope :due_for_generation, -> { active.due }

  # Creates a new Task from this template (copying over the name), then advances
  # next_run_on to the following occurrence so the same template isn't picked up again
  # until its next scheduled date. Called by GenerateRecurringTasksJob.
  #
  # Wrapped in a transaction so a failure creating the Task can't leave next_run_on
  # advanced without a Task to show for it (or vice versa) — both happen, or neither does.
  def generate_task!
    transaction do
      task = tasks.create!(name: name, done: false)
      advance_next_run_on!
      task
    end
  end

  # Moves next_run_on forward by one occurrence of this template's schedule, starting
  # from whichever is later: the date that just fired, or today. Starting from "today"
  # (rather than always adding to the old next_run_on) means a template that was paused
  # for months doesn't instantly fire a big backlog of overdue occurrences once it's
  # reactivated - it just picks up from the next sensible date going forward.
  def advance_next_run_on!
    base_date = [ next_run_on, Date.current ].max
    update!(next_run_on: next_occurrence_after(base_date))
  end

  private
    # Given a date, returns the next date this schedule should fire after it, based on
    # interval_unit ("daily"/"weekly"/"monthly") and interval_count (the "every N" part).
    def next_occurrence_after(date)
      case interval_unit
      when "daily"   then date + interval_count.days
      when "weekly"  then date + interval_count.weeks
      when "monthly" then date + interval_count.months
      end
    end
end
