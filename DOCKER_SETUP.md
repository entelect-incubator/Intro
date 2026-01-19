# Pezza PostgreSQL Docker Setup

Pre-configured PostgreSQL database with Pezza schema and sample data, ready for all Incubators (Node, Python, Java, .NET).

## Quick Start

### Option 1: Pull from GitHub Container Registry (Recommended)

```bash
# Pull the pre-built image
docker pull ghcr.io/entelect-incubator/pezza-db:latest

# Run the container
docker run -d \
  --name pezza-postgres \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=postgres \
  ghcr.io/entelect-incubator/pezza-db:latest
```

### Option 2: Build Locally

```bash
# Navigate to Intro folder
cd Intro

# Build and start with docker-compose
docker-compose up -d

# Or build manually
docker build -t pezza-db .
docker run -d --name pezza-postgres -p 5432:5432 pezza-db
```

---

## Connection Details

Once the container is running:

| Setting      | Value                                            |
| ------------ | ------------------------------------------------ |
| **Host**     | `localhost` (or `pezza-postgres` inside network) |
| **Port**     | `5432`                                           |
| **Database** | `pezza`                                          |
| **Username** | `postgres`                                       |
| **Password** | `postgres`                                       |
| **Schema**   | `pezza` (search path set automatically)          |

**Connection Strings:**

```bash
# Standard psql
psql -h localhost -p 5432 -U postgres -d pezza

# .NET (Npgsql)
Host=localhost;Port=5432;Database=pezza;Username=postgres;Password=postgres

# Java (JDBC)
jdbc:postgresql://localhost:5432/pezza?user=postgres&password=postgres

# Python (asyncpg)
postgresql://postgres:postgres@localhost:5432/pezza

# Node (pg)
postgresql://postgres:postgres@localhost:5432/pezza
```

---

## Verify Setup

Check that tables and sample data exist:

```sql
-- Connect to database
docker exec -it pezza-postgres psql -U postgres -d pezza

-- List tables
\dt pezza.*

-- Query sample data
SELECT * FROM pezza.pizzas;
SELECT * FROM pezza.customers;
SELECT * FROM pezza.orders;
```

Expected output: 2 pizzas, 2 customers, 1 sample order.

---

## Schema Details

The database includes:

- **pizzas** – Menu items with prices
- **customers** – User accounts
- **orders** – Order headers with status tracking
- **order_items** – Line items linking orders to pizzas
- **stock** – Inventory tracking per pizza
- **Trigger** – Auto-calculates order totals

See [postgres-schema.sql](postgres-schema.sql) for full DDL.

---

## GitHub Container Registry Setup

### Prerequisites

- GitHub account with repo access
- GitHub Personal Access Token (PAT) with `write:packages` scope

### Build and Push Image

```bash
# 1. Authenticate to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# 2. Build image with proper tag
docker build -t ghcr.io/entelect-incubator/pezza-db:latest ./Intro

# 3. Push to registry
docker push ghcr.io/entelect-incubator/pezza-db:latest

# Optional: Tag specific version
docker tag ghcr.io/entelect-incubator/pezza-db:latest ghcr.io/entelect-incubator/pezza-db:1.0.0
docker push ghcr.io/entelect-incubator/pezza-db:1.0.0
```

### Make Image Public

1. Go to https://github.com/orgs/entelect-incubator/packages
2. Find `pezza-db` package
3. Click "Package settings"
4. Scroll to "Danger Zone" → Change visibility to **Public**

Now anyone can pull without authentication:

```bash
docker pull ghcr.io/entelect-incubator/pezza-db:latest
```

---

## Docker Compose Integration

Add to your Incubator project's `docker-compose.yml`:

```yaml
services:
  api:
    build: .
    depends_on:
      - db
    environment:
      DATABASE_URL: postgresql://postgres:postgres@db:5432/pezza

  db:
    image: ghcr.io/entelect-incubator/pezza-db:latest
    ports:
      - "5432:5432"
    environment:
      POSTGRES_PASSWORD: postgres
```

---

## Troubleshooting

**Port already in use:**

```bash
# Check what's using port 5432
lsof -i :5432  # macOS/Linux
netstat -ano | findstr :5432  # Windows

# Stop existing container
docker stop pezza-postgres
docker rm pezza-postgres
```

**Schema not loading:**

```bash
# Check logs
docker logs pezza-postgres

# Manually run schema
docker exec -i pezza-postgres psql -U postgres -d pezza < Intro/postgres-schema.sql
```

**Connection refused:**

```bash
# Wait for postgres to be ready (healthcheck)
docker exec pezza-postgres pg_isready -U postgres -d pezza

# Check container is running
docker ps | grep pezza
```

---

## Development Workflow

```bash
# Start database
docker-compose up -d

# Run your Incubator app
npm run dev          # Node
dotnet run           # .NET
python main.py       # Python
mvn spring-boot:run  # Java

# Stop when done
docker-compose down

# Reset database (removes data volume)
docker-compose down -v
```

---

## CI/CD Integration

**GitHub Actions example:**

```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: ghcr.io/entelect-incubator/pezza-db:latest
        env:
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/pezza
        run: npm test
```

---

## Next Steps

- [Node Phase 3](../Node/Phase%203/README.md) – TypeORM with Postgres
- [Python Phase 3](../Python/Phase%203/README.md) – SQLAlchemy with Postgres
- [Java Phase 3](../Java/Phase%203/README.md) – Spring Data JPA with Postgres
- [.NET Phase 3](../.NET/Phase%203/README.md) – EF Core with Postgres

---

**Last Updated:** January 2026  
**Maintainer:** Entelect Incubator Team  
**Registry:** https://github.com/orgs/entelect-incubator/packages/container/pezza-db
