# goall-server

MCP Server for tracking your personal goals and time spent on projects.

## Features

- **Time Tracking**: Start/stop timers or manually add time entries
- **Project Management**: Organize time entries by projects
- **Multi-user Support**: Each user has their own projects and time entries
- **Reporting**: Generate reports on time spent per project/task

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- [Go 1.21+](https://golang.org/dl/)
- [golang-migrate](https://github.com/golang-migrate/migrate) CLI (can be installed via `make migrate-install`)

## Quick Start

### 1. Clone the repository

```bash
git clone <repository-url>
cd goall-server
```

### 2. Set up environment variables

```bash
cp .env.example .env
# Edit .env if you want to customize database credentials
```

### 3. Start the database and run migrations

```bash
# Install golang-migrate (if not already installed)
make migrate-install

# Start PostgreSQL and apply migrations
make setup
```

That's it! The database is now running and ready for connections.

## Available Commands

Run `make help` to see all available commands:

### Database Commands

| Command         | Description                           |
| --------------- | ------------------------------------- |
| `make db-up`    | Start PostgreSQL container            |
| `make db-down`  | Stop PostgreSQL container             |
| `make db-reset` | Reset database (destroy and recreate) |
| `make db-shell` | Open psql shell in the database       |
| `make db-logs`  | Show PostgreSQL container logs        |

### Migration Commands

| Command                      | Description                      |
| ---------------------------- | -------------------------------- |
| `make migrate-install`       | Install golang-migrate CLI       |
| `make migrate-up`            | Run all pending migrations       |
| `make migrate-down`          | Rollback the last migration      |
| `make migrate-force V=N`     | Force set migration version to N |
| `make migrate-create N=name` | Create a new migration           |
| `make migrate-version`       | Show current migration version   |

### Setup Commands

| Command      | Description                             |
| ------------ | --------------------------------------- |
| `make setup` | Full setup: start DB and run migrations |

## Database Schema

The application uses PostgreSQL with the following tables:

### Users

Stores user information for multi-user support.

| Column     | Type         | Description           |
| ---------- | ------------ | --------------------- |
| id         | UUID         | Primary key           |
| email      | VARCHAR(255) | Unique email address  |
| name       | VARCHAR(255) | Display name          |
| created_at | TIMESTAMP    | Creation timestamp    |
| updated_at | TIMESTAMP    | Last update timestamp |

### Projects

Organizes time entries into projects.

| Column      | Type         | Description           |
| ----------- | ------------ | --------------------- |
| id          | UUID         | Primary key           |
| user_id     | UUID         | Owner (FK to users)   |
| name        | VARCHAR(255) | Project name          |
| description | TEXT         | Optional description  |
| created_at  | TIMESTAMP    | Creation timestamp    |
| updated_at  | TIMESTAMP    | Last update timestamp |

### Time Entries

Records time spent on tasks.

| Column           | Type         | Description                           |
| ---------------- | ------------ | ------------------------------------- |
| id               | UUID         | Primary key                           |
| user_id          | UUID         | Owner (FK to users)                   |
| project_id       | UUID         | Optional project (FK to projects)     |
| title            | VARCHAR(255) | Entry title                           |
| description      | TEXT         | Optional description                  |
| start_time       | TIMESTAMP    | When work started                     |
| end_time         | TIMESTAMP    | When work ended (NULL = active timer) |
| duration_seconds | INTEGER      | Total duration in seconds             |
| entry_type       | ENUM         | 'timer' or 'manual'                   |
| created_at       | TIMESTAMP    | Creation timestamp                    |
| updated_at       | TIMESTAMP    | Last update timestamp                 |

## Environment Variables

| Variable            | Default      | Description         |
| ------------------- | ------------ | ------------------- |
| `POSTGRES_USER`     | goall        | Database username   |
| `POSTGRES_PASSWORD` | goall_secret | Database password   |
| `POSTGRES_DB`       | goall        | Database name       |
| `POSTGRES_PORT`     | 5432         | PostgreSQL port     |
| `DATABASE_URL`      | (computed)   | Full connection URL |

## Creating New Migrations

To create a new migration:

```bash
make migrate-create N=add_new_feature
```

This creates two files in the `migrations/` directory:

- `NNNNNN_add_new_feature.up.sql` - Apply the migration
- `NNNNNN_add_new_feature.down.sql` - Rollback the migration

## Troubleshooting

### Migration is in a dirty state

If a migration fails partway through, you may need to force the version:

```bash
# Check current version
make migrate-version

# Force to a specific version
make migrate-force V=1
```

### Cannot connect to database

1. Ensure Docker is running
2. Check if the container is up: `docker compose ps`
3. View logs: `make db-logs`
4. Verify your `.env` file matches the expected format

### Port already in use

Change `POSTGRES_PORT` in your `.env` file to an available port.

## License

[Add your license here]
