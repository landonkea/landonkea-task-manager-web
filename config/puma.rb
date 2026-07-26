# This file configures Puma, the web server that runs your Rails app.
# Puma is the program that listens for incoming HTTP requests and sends back responses.
# Think of it as the "receptionist" that receives visitors and directs them to your app.

# This configuration file will be evaluated by Puma. The top-level methods that
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.
#
# Puma starts a configurable number of processes (workers) and each process
# serves each request in a thread from an internal thread pool.
#
# You can control the number of workers using ENV["WEB_CONCURRENCY"]. You
# should only set this value when you want to run 2 or more workers. The
# default is already 1. You can set it to `auto` to automatically start a worker
# for each available processor.
#
# The ideal number of threads per worker depends both on how much time the
# application spends waiting for IO operations and on how much you wish to
# prioritize throughput over latency.
#
# As a rule of thumb, increasing the number of threads will increase how much
# traffic a given process can handle (throughput), but due to CRuby's
# Global VM Lock (GVL) it has diminishing returns and will degrade the
# response time (latency) of the application.
#
# The default is set to 3 threads as it's deemed a decent compromise between
# throughput and latency for the average Rails application.
#
# Any libraries that use a connection pool or another resource pool should
# be configured to provide at least as many connections as the number of
# threads. This includes Active Record's `pool` parameter in `database.yml`.

# `ENV.fetch("RAILS_MAX_THREADS", 3)` reads the RAILS_MAX_THREADS environment variable.
# If it's not set, it defaults to 3. This controls how many simultaneous requests
# your app can handle within a single Puma process.
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)

# `threads threads_count, threads_count` sets both the minimum and maximum thread count.
# Having them equal means Puma won't create or destroy threads dynamically --
# it keeps exactly `threads_count` threads running at all times for predictable performance.
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.

# `port ENV.fetch("PORT", 3000)` tells Puma which network port to listen on.
# It reads from the PORT environment variable, defaulting to port 3000.
# You access your app in the browser at http://localhost:3000.
port ENV.fetch("PORT", 3000)

# Allow puma to be restarted by `bin/rails restart` command.

# `plugin :tmp_restart` enables the ability to restart Puma gracefully.
# When you run `bin/rails restart`, Puma will stop the old process and start a new one
# without dropping any connections. This is essential during development.
plugin :tmp_restart

# Run the Solid Queue supervisor inside of Puma for single-server deployments.

# `plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]` starts the Solid Queue background
# job processor inside the Puma web server process. This is convenient for small apps
# that don't need a separate job-processing server. The `if` means it only activates
# when the SOLID_QUEUE_IN_PUMA environment variable is set (configured in deploy.yml).
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# Specify the PID file. Defaults to tmp/pids/server.pid in development.
# In other environments, only set the PID file if requested.

# `pidfile ENV["PIDFILE"] if ENV["PIDFILE"]` writes the process ID to a file if configured.
# A PID file lets you easily stop or check on the server process later.
# `if ENV["PIDFILE"]` means it only creates the file if you've set the PIDFILE variable.
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
