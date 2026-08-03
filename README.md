# Task Manager Web

A production-ready task management web application built with Ruby on Rails 8.1. Users can create, view, edit, and delete tasks through a clean, responsive interface.

## Features

- Full CRUD (Create, Read, Update, Delete) for tasks
- Task completion tracking (mark tasks as done/pending)
- JSON API support for all operations
- Responsive design with modern CSS
- PWA-ready with service worker support
- Background job processing with Solid Queue
- Database-backed caching with Solid Cache
- Real-time capabilities with Solid Cable (Action Cable)
- Security scanning (Brakeman, bundler-audit)
- CI/CD pipeline with GitHub Actions
- Docker-based deployment with Kamal

## Tech Stack

| Technology | Purpose |
|------------|---------|
| Ruby 3.4.9 | Programming language |
| Rails 8.1.3 | Web framework |
| SQLite3 | Database (dev/test/prod) |
| Hotwire (Turbo + Stimulus) | Frontend SPA-like navigation |
| Propshaft | Asset pipeline |
| Importmap | JavaScript delivery without Node.js |
| Solid Queue | Background job processing |
| Solid Cache | Database-backed caching |
| Solid Cable | WebSocket support |
| Kamal | Docker-based deployment |
| Thruster | HTTP caching/compression proxy |
| Puma | Web server |
| Minitest | Testing framework |
| RuboCop | Code linting |
| Brakeman | Security scanning |

## Getting Started

### Prerequisites

- Ruby 3.4.9 (see `.ruby-version`)
- SQLite3
- Bundler

### Setup

```sh
# Install dependencies
bundle install

# Set up the database with sample data
bin/rails db:prepare

# Start the development server
bin/dev
```

The app will be available at `http://localhost:3000`.

### Running Tests

```sh
bin/rails test
```

### Running Linter

```sh
bin/rubocop
```

### Persisted Test Report

`bin/rails test_report` runs `bin/rails test` and `bin/rubocop` and writes a
summary (pass/fail counts, timestamp, failing tests, RuboCop offense count) to
`test-results/latest.md`. The report is regenerated on every run and is
gitignored -- it's a build artifact, not something to commit.

```sh
bin/rails test_report
```

The task exits non-zero if either check fails, so it can be used as a CI gate.
CI runs it as an additive step and uploads `test-results/latest.md` as a
downloadable build artifact (see `.github/workflows/ci.yml`).

### Security Scans

```sh
bin/brakeman --no-pager
bin/bundler-audit
```

## Docker

### Build the Image

```sh
docker build -t task_manager_web .
```

### Run the Container

```sh
docker run -d \
  -p 80:80 \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  --name task_manager_web \
  task_manager_web
```

### docker-compose (standalone local dev)

`docker-compose.yml` builds the same Dockerfile Kamal deploys and runs it
locally -- a quick way to run the app in a container without installing Ruby.
The app is SQLite-based (see `config/database.yml`) with no separate database
server, so there's just one `web` service; its `storage/` directory (SQLite
files, Active Storage uploads) is bind-mounted so data survives rebuilds.

```sh
echo "RAILS_MASTER_KEY=$(cat config/master.key)" > .env
docker compose up --build
```

The app is then available at `http://localhost:3000`. Note the image bakes in
`RAILS_ENV=production`, so this runs against `storage/production.sqlite3`,
mirroring a real Kamal deploy rather than `bin/dev`'s development environment.

## Environments

This app has three environments: `development` (your machine), `staging`, and
`production`. Staging and production both deploy to the same LAN server
(`192.168.0.1`) via Kamal, but as completely separate containers with their own
image, volume, and SQLite database files -- they never share state.

| Environment | Where it runs | Config | Database files |
|-------------|----------------|--------|-----------------|
| development | Your machine (`bin/dev`) | `config/environments/development.rb` | `storage/development.sqlite3` |
| test        | Your machine (`bin/rails test`) | `config/environments/test.rb` | `storage/test.sqlite3` |
| staging     | `192.168.0.1` via Kamal | `config/environments/staging.rb`, `config/deploy.staging.yml` | `storage/staging*.sqlite3` |
| production  | `192.168.0.1` via Kamal | `config/environments/production.rb`, `config/deploy.yml` | `storage/production*.sqlite3` |

Staging exists to let you deploy and poke at a real Kamal build before it goes to
production, without touching production's data or containers. Deploy to it with:

```sh
bin/kamal deploy -d staging
```

Since staging shares the host's single kamal-proxy with production, it's reached by
Host header rather than a separate domain (there's no public DNS for this LAN-only
server):

```sh
curl -H "Host: task-manager-staging.lan" http://192.168.0.1/
```

Kamal commands accept `-d staging` to target the staging destination (e.g. `bin/kamal
logs -d staging`, `bin/kamal console -d staging`). Omit `-d` to target production.

## API Usage

All endpoints support both HTML and JSON responses.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/tasks` | List all tasks |
| GET | `/tasks/:id` | Show a specific task |
| POST | `/tasks` | Create a new task |
| PATCH/PUT | `/tasks/:id` | Update a task |
| DELETE | `/tasks/:id` | Delete a task |
| GET | `/up` | Health check |

### Example JSON Request

```sh
curl -X POST http://localhost:3000/tasks \
  -H "Content-Type: application/json" \
  -d '{"task": {"name": "Buy groceries", "done": false}}'
```

## Project Structure

```
app/
  controllers/    # Handle web requests
  models/         # Business logic and database
  views/          # HTML templates
  javascript/     # Frontend JS (Stimulus controllers)
  assets/         # CSS stylesheets
config/           # App configuration
db/               # Database schema and migrations
test/             # Test suite
```

## License

This project is open source and available under the MIT License.
