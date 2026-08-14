# This job is the "engine" behind recurring tasks. It's scheduled to run automatically
# (see config/recurring.yml) via Solid Queue, Rails' built-in background job processor.
#
# Each time it runs, it finds every RecurringTask template that's active and due, spawns
# a fresh Task from each one, and advances that template's schedule to its next
# occurrence — so a "water the plants every week" template quietly keeps producing a new
# to-do item every week without anyone having to remember to create it.
class GenerateRecurringTasksJob < ApplicationJob
  # "default" is the queue this job runs on - there's only one worker pool in this app
  # (see config/queue.yml, which has workers listening to queues: "*"), so this mostly
  # documents intent rather than changing behavior.
  queue_as :default

  def perform
    # .find_each loads templates in small batches (1000 by default) instead of all at
    # once - this keeps memory usage flat even if the number of recurring templates
    # grows a lot, unlike .each which would load every matching row into memory upfront.
    RecurringTask.due_for_generation.find_each do |recurring_task|
      # generate_task! creates the new Task AND advances next_run_on in one transaction
      # (see app/models/recurring_task.rb) - so a template's schedule only moves forward
      # once its Task has actually been created.
      recurring_task.generate_task!
    end
  end
end
