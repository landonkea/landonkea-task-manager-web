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
