# Build Log

How this app got to its current state, and how to get back to that state from
nothing but the git history. Written for someone who's never seen a Rails app
before, so it spells out things a Rails developer would consider obvious.

Two things this document is NOT about: it doesn't cover PR #2 ("Add recurring task
generation"), which is open, failing CI, and intentionally untouched - main is the
only branch described here. And it's not a tutorial on Rails itself; it's a record
of what actually happened to this specific repo, in order.

## How it actually happened

This comes straight from `git log --reverse main`, condensed to the commits that
changed something meaningful (dependency bumps and merge commits are collapsed into
the milestones they belong to).

**July 17, 2026 - `feebf96` - "initial rails app with task scaffold."** The starting
point: `rails new` plus `bin/rails generate scaffold Task name:string done:boolean`,
which is where `app/controllers/tasks_controller.rb`, the task views, and the first
migration (`db/migrate/20260717201431_create_tasks.rb`) all came from. Rails 8's
generators already include a Dockerfile, `config/deploy.yml`, and a GitHub Actions
CI workflow by default, so those existed from this very first commit too, not added
later.

**July 25, 2026 - `08a7981` - "feat: comprehensive QA, comments, and production
improvements."** The big pass that turned a bare scaffold into what's here now:
line-by-line comments explaining what every file does (the kind you're reading in
this one), the Minitest suite under `test/`, and a round of hardening. This is the
commit that set the tone for everything after it - every file added later kept the
same heavily-commented style.

**Late July / early August - dependency bumps.** Six Dependabot PRs merged in quick
succession: `actions/checkout` 6→7, `actions/upload-artifact` 4→7, `actions/cache`
4→6, `image_processing` 1.14.0→2.0.2, `solid_cable` 4.0.0→4.0.2, `solid_queue`
1.4.0→1.5.0. Ordinary maintenance, but two of them had follow-on consequences below.

**August 1, 2026 - `563b9bc` - "Fix broken CI workflow YAML (misplaced comment breaks
block scalar)."** A comment landed in the wrong spot in `.github/workflows/ci.yml`
and broke YAML parsing. Worth remembering: adding comments to YAML is not risk-free
the way it is in Ruby - a comment on the wrong line can change what the file means.

**August 1, 2026 - PR #7, "chore/staging-environment-and-cleanup."** This is where
staging was born: `768aa57` added `config/environments/staging.rb` and
`config/deploy.staging.yml`, and fixed a hardcoded mailer host that would have broken
email links outside development. Three follow-up commits in the same PR fixed things
that only broke once staging was real: `c5245cf` added an explicit `ruby-vips`
dependency (`image_processing` 2.0 stopped bundling it, silently, as part of that
Dependabot bump above), `c330a61` installed `libvips` in the CI `scan_js` job (booting
Rails for `importmap audit` pulls in `ruby-vips` even though that job never touches
an image), and `bb8f3a0` added a missing `test/system/application_system_test_case.rb`
that system tests needed to run at all.

**August 1, 2026 - `ae97357` - "Add missing staging: section to config/cable.yml."**
A direct follow-up commit, not part of a PR. Staging's `RAILS_ENV=staging` crashed at
boot the moment eager loading reached Solid Cable's initializer, because
`config/cable.yml` had no `staging:` key for it to `connects_to`. Worth remembering
for the dev/staging/prod work below - the same class of bug was worth checking for in
`config/queue.yml` too, so it now has explicit `staging:` and `dev:` sections as well,
even though nothing forced the issue there yet.

**August 2, 2026 - `5d43497` - "Add secret_key_base to credentials."** Rails needs a
`secret_key_base` in `config/credentials.yml.enc` for session cookies, CSRF tokens,
and the like. This commit only changes the encrypted file - the change itself isn't
readable without `config/master.key`, which was never committed (see `.gitignore`).

**August 2, 2026 - PR #9, "chore/add-bullet-gem."** Added the `bullet` gem, wired up
in `config/environments/development.rb`, so N+1 queries get flagged in the browser
and the Rails log while developing locally. Development-only; it doesn't run in
staging, dev, or production.

**August 3-12, 2026 - PR #1, "feature/auth-categories-search."** The most recent
merged feature. `6d8e133` added a minimal single-user auth gate (`User`, `Session`,
`app/controllers/concerns/authentication.rb`, the `resource :session` route) plus
`category` and search on `Task` (`db/migrate/20260803082604_add_category_to_tasks.rb`,
the `Task.search` and `Task.in_category` scopes). "Single-user" is deliberate here -
there's no signup form, because `db/seeds.rb` is what creates the one account that's
allowed to log in, from `ADMIN_EMAIL`/`ADMIN_PASSWORD`. This PR merged as `6b1c587`,
which is the current tip of `main`.

That's the whole history. Everything in the working tree today traces back to one of
these commits.

## Rebuilding from nothing, with no human in the loop

The honest answer to "how do you rebuild this with zero manual input" is: the source
code already exists, in git. The commit history above IS the build process - it's not
something a script regenerates from scratch, because half of it is hand-written
application logic (controllers, views, auth, scopes) that no generator produces on
its own. What CAN be fully automated is going from an empty machine to a running
instance of the app that's already in version control. That's the actual disaster-
recovery scenario this section answers: your laptop dies, or the server disk dies,
and you need the app back with nobody available to click through a setup wizard.

```sh
# 1. Get the source. Nothing here needs a human beyond having the repo URL.
git clone <this-repo-url> task-manager-web
cd task-manager-web

# 2. Get the right Ruby. rbenv/asdf/mise all read .ruby-version automatically;
#    this example uses rbenv.
rbenv install --skip-existing "$(cat .ruby-version)"
rbenv local "$(cat .ruby-version)"

# 3. Install gems. bin/setup (see below) does this plus steps 4-5 in one call,
#    but spelled out here for clarity:
gem install bundler
bundle install

# 4. Create and migrate the database. db:prepare is idempotent - safe to run
#    on a fresh machine or an existing one.
bin/rails db:prepare

# 5. Load seed data - the single admin login (from ADMIN_EMAIL/ADMIN_PASSWORD,
#    or a dev-only default if those aren't set - see db/seeds.rb) plus 8 sample
#    tasks.
bin/rails db:seed

# 6. Run the test suite to confirm the rebuild actually matches what's in git.
bin/rails db:test:prepare test

# 7. Start the app.
bin/dev
```

Steps 2 through 6 are exactly `bin/setup`, which already exists in this repo for
this reason - `bin/setup` (or `bin/setup --skip-server`) does all of it in one
command, then hands off to `bin/dev` unless told not to.

Two things above are the closest this process gets to needing a human, and both are
inherent to how secrets work, not something automation can paper over:

- **`config/master.key`.** Decrypts `config/credentials.yml.enc` (which holds
  `secret_key_base`). It's gitignored on purpose - if it's not on the new machine,
  someone with access to it has to copy it over once, out of band. There's no way
  to "automate" recreating a secret that was deliberately never stored in git.
- **`ADMIN_EMAIL` / `ADMIN_PASSWORD`.** Optional in development (falls back to
  `admin@example.com` / `password123`, see `db/seeds.rb`), but for anything deployed,
  these need to be real values from a real environment, not generated by a script.

Everything else above - Ruby version, gems, schema, seed data, running the app - is
fully deterministic from what's already committed. Run it on any machine with
network access and you get the same app.

### If you actually had to start from an empty directory (no git history at all)

This is the scaffold-and-generate path the commits above followed, for completeness.
It won't reproduce the hand-written logic in `app/controllers/tasks_controller.rb`,
`app/models/task.rb`, or the auth/category work from PR #1 - only Rails generators
can be scripted this precisely, and generators stop at scaffolding, not business
logic:

```sh
rails new task-manager-web --database=sqlite3
cd task-manager-web
bin/rails generate scaffold Task name:string done:boolean
bin/rails generate model User email_address:string:uniq password_digest:string
bin/rails generate model Session user:references ip_address:string user_agent:string
bin/rails generate migration AddCategoryToTasks category:string
bin/rails db:migrate
bundle add bullet --group development
```

From there, someone has to actually write `Authentication` concern, the `Task`
model's validations and scopes, the auth-gated controllers, and every view - the
part of this repo that makes it a task manager and not a generic CRUD demo.

## How CI is wired

`.github/workflows/ci.yml` runs on every pull request and on every push to `main`.
Five jobs, all independent of each other (they run in parallel, not in sequence):

- **`scan_ruby`** - Brakeman (`bin/brakeman --no-pager`) for Rails-specific security
  issues, and `bundler-audit` for gems with known CVEs.
- **`scan_js`** - `bin/importmap audit` for JS dependencies pulled in via importmap.
  Needs `libvips` installed on the runner even though it never touches an image,
  because booting Rails at all (which this command does) loads `ruby-vips` - see the
  `c330a61` commit above for why that's there.
- **`lint`** - RuboCop, with a GitHub Actions cache keyed on `.ruby-version`,
  `.rubocop.yml`, and `Gemfile.lock` so unrelated commits don't re-lint from scratch.
- **`test`** - `bin/rails db:test:prepare test`, the Minitest suite from `test/`.
- **`system-test`** - Capybara-driven browser tests (`test:system`), with failure
  screenshots uploaded as a build artifact so a failure is debuggable from the
  Actions UI without reproducing it locally.

None of these jobs currently need `RAILS_MASTER_KEY` - the commented-out lines in
`ci.yml` show where it would go if a job ever needed to decrypt credentials.

## How Kamal is wired

Kamal builds a Docker image from the multi-stage `Dockerfile` (build stage installs
gems and precompiles assets; the final stage is a slim runtime image running as a
non-root `rails` user) and runs it on a target server over SSH. `bin/kamal` is a
Bundler-generated wrapper, same idea as `bin/rails`.

There are now three deploy destinations, each its own `config/deploy.<name>.yml`
file deep-merged over the base `config/deploy.yml`:

| Destination | Command | Service name | Rails env |
|---|---|---|---|
| production | `bin/kamal deploy` | `task_manager_web` | `production` |
| staging | `bin/kamal deploy -d staging` | `task_manager_web-staging` | `staging` |
| dev | `bin/kamal deploy -d dev` | `task_manager_web-dev` | `dev` |

All three currently point at the same placeholder LAN address (`192.168.0.1`) as
completely separate containers - distinct image names, distinct Docker volumes for
their SQLite files, distinct Host-header routing through the shared kamal-proxy. No
server actually answers there yet; this is the pipeline wired and ready, not a live
deployment. See the "Environments" section of `README.md` for the day-to-day commands.

Secrets never live in these YAML files - only the ENV VAR NAMES Kamal should look
for do. The actual values come from `.kamal/secrets`, a small script Kamal runs at
deploy time: `RAILS_MASTER_KEY` reads from the local `config/master.key` file, and
`ADMIN_EMAIL`/`ADMIN_PASSWORD` read from whatever's already exported in the
deploying shell. The `.env.dev.example`, `.env.staging.example`, and
`.env.production.example` files at the repo root document exactly which shell
variables each destination needs and hold placeholder values only - copy one to its
non-`.example` name, fill in real values, `source` it, then deploy. The real
`.env.*` files are gitignored; only the `.example` templates are meant to be committed.
