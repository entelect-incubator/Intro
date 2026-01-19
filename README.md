# Pezza - While it's hot

![Pezza - While it's hot](https://github.com/entelect-incubator/.NET/raw/master/Phase%207/pezza-logo.png)

Established in 1940, Pezza has been a small family run restaurant for many generations. In 2020, they decided to expand and open more branches, to share their amazing family secret pizza's with more people.

To make this a reality they decided that going digital will be there number one priority. They partnered up with a South African Software Solutions Company to help them to go digital. They realized that they needed to build back office systems, and allow customers to order pizza's online. Part of the agreement was that some of the family members would assist in the developement and maintenance of the systems.

# Introduction

Pezza has throughout its history placed great value on training and decided to kick off a training initiative as part of their new venture into digital. The training will be available to all family members who wish to participate in helping their family business. In Software Engineering it is very important to understand the fundamentals. This is why this training program will cover everything, starting from the fundamentals, all the way to advanced concepts.

The training will be focused on actual problems that Software Developers have faced at and how to prevent these problems from occurring over and over again, and how to implement best practices on every team.

## High Level Requirement

 - Pizza Stock
 - Pizza Ordering
 - Notifications

Use the Pezza Postgres schema to bootstrap databases across incubators.

- Schema file: [Intro/postgres-schema.sql](postgres-schema.sql)
- **Docker Setup**: [DOCKER_SETUP.md](DOCKER_SETUP.md) – Pre-built PostgreSQL image with schema and sample data

### Docker Quick Start (Recommended)

```bash
# Pull pre-configured database with schema and sample data
docker pull ghcr.io/entelect-incubator/pezza-db:latest

# Run container
docker run -d --name pezza-postgres -p 5432:5432 \
  -e POSTGRES_PASSWORD=postgres \
  ghcr.io/entelect-incubator/pezza-db:latest

# Connect: postgresql://postgres:postgres@localhost:5432/pezza
```

See [DOCKER_SETUP.md](DOCKER_SETUP.md) for full documentation, GitHub Container Registry setup, and CI/CD integration.

### Manual Import (Alternative)

```bash
# Create database (if not exists)
createdb pezza

# Import schema
psql -d pezza -f Intro/postgres-schema.sql
```

This schema models pizzas, customers, orders, order items, and stock with sensible constraints and example data. It is compatible with EF Core (Npgsql) for .NET, as well as ORMs/libs in Java, Python, and Node.

## Pezza API (Docker)

Use the published Pezza API Docker image from GitHub Container Registry to quickly bootstrap API development across all incubators.

- Published Image: `ghcr.io/entelect-incubator/pezza-api:latest`
- **Quick Start**: [API_DOCKER_SETUP.md](API_DOCKER_SETUP.md) – Pull image, configure environment, and run with docker-compose

### Docker Quick Start (Recommended)

```bash
# Pull published API image
docker pull ghcr.io/entelect-incubator/pezza-api:latest

# Run container (example with docker-compose)
# See API_DOCKER_SETUP.md for full docker-compose.yml
docker-compose up -d

# API available at http://localhost:5000
```

See [API_DOCKER_SETUP.md](API_DOCKER_SETUP.md) for full documentation, environment configuration, and integration with database.
