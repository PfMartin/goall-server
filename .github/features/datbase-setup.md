# Project Database setup

## Description

Create a database setup using docker compose and postgres. A database container should be created with a dedicated user, my application `goall-server` can use for connections using golang.

- Authentication is required for all connections
- Setup scripts are in place, so each new developer, which clones the repo can setup their own database with just a few sets of scripts
- Create a database schema from the [application description](./application-description.md)
- Code and scripts should be reused in other scripts, follow the dry principle
- A comprehensive documentation for new developers in the README.md file should be created
