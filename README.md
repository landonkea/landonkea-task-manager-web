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

## Environments

This app has five environments: `development` (your machine), `test` (your machine),
and three deployed Kamal destinations that form a pipeline - `dev`, `staging`, and
`production`, roughly in the order code passes through them. All three deployed
destinations point at the same LAN server (`192.168.0.1`) via Kamal, but as completely
separate containers with their own image, volume, and SQLite database files -- they
never share state, and a bug in one can't touch the others' data.

| Environment | Where it runs | Config | Database files |
|-------------|----------------|--------|-----------------|
| development | Your machine (`bin/dev`) | `config/environments/development.rb` | `storage/development.sqlite3` |
| test        | Your machine (`bin/rails test`) | `config/environments/test.rb` | `storage/test.sqlite3` |
| dev         | `192.168.0.1` via Kamal | `config/environments/dev.rb`, `config/deploy.dev.yml` | `storage/dev*.sqlite3` |
| staging     | `192.168.0.1` via Kamal | `config/environments/staging.rb`, `config/deploy.staging.yml` | `storage/staging*.sqlite3` |
| production  | `192.168.0.1` via Kamal | `config/environments/production.rb`, `config/deploy.yml` | `storage/production*.sqlite3` |

Note that "dev" (deployed, Docker-based, production-like) and "development" (your
machine, `bin/dev`, live code reloading) are deliberately different things - see the
comment at the top of `config/environments/dev.rb` if that's confusing.

Dev and staging exist to let you deploy and poke at a real Kamal build before it goes
to production, without touching production's data or containers - dev first, for
active debugging of a freshly landed change (it shows full error pages), then staging,
for a final check against something closer to production's own settings. Deploy to
either with:

```sh
bin/kamal deploy -d dev
bin/kamal deploy -d staging
```

Both need `ADMIN_EMAIL` and `ADMIN_PASSWORD` set in your shell first (see
`.env.dev.example` / `.env.staging.example` / `.env.production.example`), since
`db/seeds.rb` reads them as Kamal secrets to create that destination's login.

Since all three destinations share the host's single kamal-proxy, each is reached by
Host header rather than a separate domain (there's no public DNS for this LAN-only
server):

```sh
curl -H "Host: task-manager-dev.lan" http://192.168.0.1/
curl -H "Host: task-manager-staging.lan" http://192.168.0.1/
```

Kamal commands accept `-d dev` or `-d staging` to target that destination (e.g.
`bin/kamal logs -d dev`, `bin/kamal console -d staging`). Omit `-d` to target production.

No server currently answers at `192.168.0.1` for any of these three destinations - the
config above is real and ready to use, but nothing has actually been deployed yet.

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
