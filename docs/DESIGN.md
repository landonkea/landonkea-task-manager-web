# landonkea-task-manager-web — Design & Workflow

## High-Level Overview

```mermaid
graph TB
    subgraph "Rails 8.1 App"
        A[Puma] --> B[Controllers]
        B --> C[Models]
        C --> D[(SQLite)]
        B --> E[Hotwire]
        E --> F[Turbo]
        E --> G[Stimulus]
    end

    subgraph "Background"
        H[Solid Queue] --> I[Jobs]
        J[Solid Cache] --> K[Caching]
        L[Solid Cable] --> M[WebSockets]
    end

    subgraph "Deployment"
        N[Kamal] --> O[Docker]
        O --> P[Thruster Proxy]
    end
```

## Task CRUD Flow

```mermaid
sequenceDiagram
    participant B as Browser
    participant C as Controller
    participant M as Task Model
    participant D as SQLite

    B->>C: GET /tasks
    C->>M: Task.all
    M->>D: SELECT * FROM tasks
    D-->>M: Task list
    M-->>C: Collection
    C-->>B: HTML/JSON response

    B->>C: POST /tasks
    C->>M: Task.new(params)
    M->>D: INSERT INTO tasks
    D-->>M: Saved
    M-->>C: Task
    C-->>B: Redirect/JSON
```

## Real-Time Updates

```mermaid
flowchart TD
    A[User action] --> B[Controller]
    B --> C[Broadcast via Turbo]
    C --> D[All connected browsers]
    D --> E[DOM updates automatically]
```

## File Relationships

| File | Purpose | Used By |
|------|---------|---------|
| `app/controllers/tasks_controller.rb` | CRUD handlers | Routes |
| `app/models/task.rb` | Business logic | Controller |
| `app/views/` | HTML templates | Controller |
| `app/javascript/` | Stimulus controllers | Turbo |
| `config/deploy.yml` | Kamal config | Deployment |
| `db/schema.rb` | Database schema | Models |

## draw.io

[Open in draw.io](https://app.diagrams.net/#RTask%20manager%20architecture)
