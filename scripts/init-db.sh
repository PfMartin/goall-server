#!/bin/bash
set -e

# This script runs automatically on first PostgreSQL container start
# It ensures the database and user are properly configured

echo "Initializing goall database..."

# The POSTGRES_USER, POSTGRES_PASSWORD, and POSTGRES_DB are already created
# by the official postgres image. This script adds any additional setup.

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Ensure UUID extension is available
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    
    -- Grant all privileges on the database to the application user
    GRANT ALL PRIVILEGES ON DATABASE "$POSTGRES_DB" TO "$POSTGRES_USER";
    
    -- Ensure the user can create tables and other objects
    GRANT ALL ON SCHEMA public TO "$POSTGRES_USER";
    
    SELECT 'Database initialization completed successfully' AS status;
EOSQL

echo "Database initialization completed!"
