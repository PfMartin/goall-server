-- Rollback initial schema

-- Drop triggers first
DROP TRIGGER IF EXISTS update_time_entries_updated_at ON time_entries;
DROP TRIGGER IF EXISTS update_projects_updated_at ON projects;
DROP TRIGGER IF EXISTS update_users_updated_at ON users;

-- Drop function
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Drop tables in reverse order of creation (respecting foreign keys)
DROP TABLE IF EXISTS time_entries;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS users;

-- Drop custom types
DROP TYPE IF EXISTS time_entry_type;
