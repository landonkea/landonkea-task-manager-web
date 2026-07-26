# This file defines the ApplicationJob, which is the parent class for ALL background jobs.
# Background jobs let you run slow tasks (like sending emails or processing uploads) in the
# background so your website stays fast and responsive for users.

# ApplicationJob inherits from ActiveJob::Base, which is Rails' built-in system for
# managing background tasks. It handles queuing, retries, and scheduling.
class ApplicationJob < ActiveJob::Base
  # The lines below are commented out (they don't run), but they show useful options
  # you can enable later as your app grows:

  # "retry_on" tells Rails to automatically retry a job if it hits a database deadlock.
  # A deadlock is when two database operations get stuck waiting for each other.
  # This is commented out by default — uncomment it if your app has heavy database usage.
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # "discard_on" tells Rails to silently throw away (not retry) a job if the data it
  # needs no longer exists in the database. For example, if a job was supposed to email
  # a user but that user was deleted, there's no point retrying.
  # This is commented out by default — uncomment it based on your needs.
  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
