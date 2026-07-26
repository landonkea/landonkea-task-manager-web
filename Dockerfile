# syntax=docker/dockerfile:1
# Tells Docker which version of the Dockerfile syntax to use for parsing.
# This ensures you get the latest BuildKit features and avoids compatibility issues.

# check=error=true
# Enables Docker's built-in linter (CheckKit) and treats any warnings as errors.
# This catches best-practice violations early so your image stays secure and efficient.

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t task_manager_web .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name task_manager_web task_manager_web
# Documents the intended use of this file and shows the exact commands to build and run manually.
# Included so any developer can quickly spin up a container without digging through docs.

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html
# Points you to the official Rails guide for setting up a Dev Container, which is the recommended
# approach for local development rather than using this production Dockerfile.

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
# Reminds you to keep the Ruby version in sync with the project's .ruby-version file.
# A mismatch would cause confusing errors where gems compiled against one version fail at runtime.

ARG RUBY_VERSION=3.4.9
# Declares a build argument called RUBY_VERSION with a default value.
# This acts like a variable you can override at build time (e.g., --build-arg RUBY_VERSION=3.3.0).

FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base
# Starts the image from the official Ruby "slim" image (minimal Debian + Ruby).
# The "slim" variant removes unnecessary packages to keep the final image small and fast to pull.
# "base" names this stage so other stages can reference it later.

# Rails app lives here
# Comment explaining the next line's purpose.
WORKDIR /rails
# Sets the working directory inside the container to /rails.
# Every subsequent RUN, COPY, and CMD will use this directory as the starting point.

# Install base packages
# Comment summarizing the upcoming RUN command.
RUN apt-get update -qq && \
# Updates the list of available packages (-qq suppresses verbose output).
# The backslash continues the command on the next line for readability.
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
# Installs only the essential runtime packages: curl (HTTP client), libjemalloc2 (memory allocator),
# libvips (image processing), and sqlite3 (database). --no-install-recommends skips optional deps.
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
# Creates a symlink for jemalloc so Rails can find it regardless of CPU architecture (x86_64 vs arm64).
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
# Cleans up the apt cache to reduce the image size. Cached packages are never needed after installation.

# Set production environment variables and enable jemalloc for reduced memory usage and latency.
# Explains why the ENV block exists and mentions the performance benefit of jemalloc.
ENV RAILS_ENV="production" \
# Tells Rails to run in production mode, which enables caching and disables detailed error pages.
    BUNDLE_DEPLOYMENT="1" \
# Tells Bundler it's a deployment: no Gemfile changes allowed, strict resolution.
    BUNDLE_PATH="/usr/local/bundle" \
# Sets where gems are installed. This path is shared across stages to avoid reinstalling.
    BUNDLE_WITHOUT="development" \
# Skips installing development-only gems (like debug tools) to keep the image lean.
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"
# Forces every process in the container to use jemalloc, reducing memory fragmentation.

# Throw-away build stage to reduce size of final image
# Explains the multi-stage build strategy: build in a fat stage, copy artifacts to a thin final stage.
FROM base AS build
# Creates a new stage called "build" that inherits everything from the "base" stage.
# This stage will be discarded after the build, taking its large build tools with it.

# Install packages needed to build gems
# Comment before the build-tool installation step.
RUN apt-get update -qq && \
# Refreshes the package list again (the build stage is a fresh layer).
    apt-get install --no-install-recommends -y build-essential git libvips libyaml-dev pkg-config && \
# Installs compilers and dev headers needed to compile native gem extensions (like psych, nokogiri).
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
# Cleans apt caches again to keep the build layer as small as possible.

# Install application gems
# Signals the start of the gem installation section.
COPY vendor/* ./vendor/
# Copies any vendored (pre-downloaded) gems into the container. This enables offline or pinned gems.
COPY Gemfile Gemfile.lock ./
# Copies the Gemfile and its lockfile so Bundler knows which gems and exact versions to install.

RUN bundle install && \
# Runs Bundler to install all gems specified in the Gemfile. Uses the lockfile for reproducibility.
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
# Removes Bundler caches and .git folders from vendored gems to reduce image size.
    # -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
    # Documents why single-threaded compilation is used — it works around a known emulation bug.
    bundle exec bootsnap precompile -j 1 --gemfile
# Precompiles Bootsnap caches for gems, which speeds up application boot time in production.

# Copy application code
# Comment indicating the source code copy step.
COPY . .
# Copies the entire Rails application source code into the container's working directory.

# Precompile bootsnap code for faster boot times.
# -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
# Explains the second Bootsnap pass and why -j 1 is used.
RUN bundle exec bootsnap precompile -j 1 app/ lib/
# Precompiles Bootsnap caches specifically for app/ and lib/ code, cutting seconds off cold boots.

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# Notes that asset compilation can run without the real secret key by using a dummy placeholder.
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile
# Runs the Rails asset pipeline to compile CSS, JS, and images into the public/ directory.
# SECRET_KEY_BASE_DUMMY=1 fakes the secret so the task doesn't error out in a build-only context.


# Final stage for app image
# Marks the start of the slim, production-ready image that will actually be deployed.
FROM base
# Starts fresh from the "base" stage (no build tools, no source code yet).

# Run and own only the runtime files as a non-root user for security
# Explains the security rationale: running as root inside a container is risky if the app is compromised.
RUN groupadd --system --gid 1000 rails && \
# Creates a system group called "rails" with a fixed GID of 1000.
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
# Creates a "rails" user with UID 1000, assigned to the rails group, with a home dir and bash shell.
USER 1000:1000
# Switches the container to run as the rails user/group. All following commands execute as this user.

# Copy built artifacts: gems, application
# Documents what's being copied from the build stage into the final image.
COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
# Copies the installed gems from the build stage and ownership to the rails user.
COPY --chown=rails:rails --from=build /rails /rails
# Copies the compiled Rails application (including precompiled assets) from the build stage.

# Entrypoint prepares the database.
# Explains that the entrypoint script handles tasks like db:create and db:migrate before the server starts.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
# Sets the entrypoint script that runs every time the container starts (e.g., runs migrations first).

# Start server via Thruster by default, this can be overwritten at runtime
# Explains that Thruster (a Rails-recommended HTTP proxy) is the default server process.
EXPOSE 80
# Documents that the container listens on port 80. This is metadata — it doesn't publish the port.
CMD ["./bin/thrust", "./bin/rails", "server"]
# The default command: launches Thruster which in turn starts the Rails server on port 80.
