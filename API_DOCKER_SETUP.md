# Pezza API - Docker Setup Guide

The Pezza API is published to GitHub Container Registry (GHCR) and ready for consumption by frontend incubators and development teams.

## Quick Start with Docker Compose

### Prerequisites

- Docker & Docker Compose installed
- GitHub credentials (if using private registry)

### Basic Setup

1. **Create a `docker-compose.yml`**:

```yaml
version: '3.8'

services:
  pezza-api:
    image: ghcr.io/entelect-incubator/pezza-api:latest
    container_name: pezza-api
    ports:
      - "5000:5000"
    environment:
      - ConnectionStrings__DefaultConnection=Server=pezza-db;Port=5432;User Id=postgres;Password=postgres;Database=pezza;
      - ASPNETCORE_ENVIRONMENT=Development
    depends_on:
      - pezza-db
    networks:
      - pezza-network

  pezza-db:
    image: ghcr.io/entelect-incubator/pezza-db:latest
    container_name: pezza-postgres
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_PASSWORD=postgres
    networks:
      - pezza-network

networks:
  pezza-network:
    driver: bridge
```

2. **Start the services**:

```bash
docker-compose up -d
```

3. **Verify the API is running**:

```bash
curl http://localhost:5000/health
```

## Environment Variables

Configure these variables based on your deployment environment:

| Variable                               | Default                                                                        | Description                                             |
| -------------------------------------- | ------------------------------------------------------------------------------ | ------------------------------------------------------- |
| `ConnectionStrings__DefaultConnection` | `Server=pezza-db;Port=5432;User Id=postgres;Password=postgres;Database=pezza;` | PostgreSQL connection string                            |
| `ASPNETCORE_ENVIRONMENT`               | `Production`                                                                   | Deployment environment (Development/Staging/Production) |
| `ASPNETCORE_URLS`                      | `http://+:5000`                                                                | API listen address                                      |
| `LOG_LEVEL`                            | `Information`                                                                  | Structured logging level                                |

## Using with Frontend Incubators

### React/Angular Frontend Example

```yaml
version: '3.8'

services:
  frontend:
    image: my-frontend:latest
    ports:
      - "3000:3000"
    environment:
      - REACT_APP_API_URL=http://pezza-api:5000
    depends_on:
      - pezza-api
    networks:
      - pezza-network

  pezza-api:
    image: ghcr.io/entelect-incubator/pezza-api:latest
    container_name: pezza-api
    ports:
      - "5000:5000"
    environment:
      - ConnectionStrings__DefaultConnection=Server=pezza-db;Port=5432;User Id=postgres;Password=postgres;Database=pezza;
    depends_on:
      - pezza-db
    networks:
      - pezza-network

  pezza-db:
    image: ghcr.io/entelect-incubator/pezza-db:latest
    container_name: pezza-postgres
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_PASSWORD=postgres
    networks:
      - pezza-network

networks:
  pezza-network:
    driver: bridge
```

## API Endpoints

The Pezza API provides REST endpoints for:

- **Pizzas**: GET/POST pizzas, query by ID
- **Orders**: Create orders, list customer orders
- **Stock**: Query available pizza stock
- **Delivery**: Track delivery status, manage order delivery

See the published API documentation or Phase 14 Final Solution for full endpoint details.

## Pulling the Image

### Public Access

```bash
docker pull ghcr.io/entelect-incubator/pezza-api:latest
```

### With Authentication (Private Registry)

```bash
# Create GitHub Personal Access Token (PAT) with read:packages scope
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u <username> --password-stdin

# Pull the image
docker pull ghcr.io/entelect-incubator/pezza-api:latest
```

## Troubleshooting

### Container Won't Start

Check logs:
```bash
docker logs pezza-api
```

Verify connection string:
```bash
# Test database connectivity
docker exec pezza-api dotnet user-secrets list
```

### Health Check

```bash
# Basic health check
curl http://localhost:5000/health

# Detailed diagnostics
curl http://localhost:5000/health/detailed
```

### Database Connection Issues

Ensure pezza-db is running and healthy:
```bash
docker ps | grep pezza
docker logs pezza-postgres
```

## Tagging & Versions

Images are tagged with:

- `latest` - Most recent stable release
- `v1.0.0` - Semantic versioning
- Git SHA - Specific commit: `ghcr.io/entelect-incubator/pezza-api:<sha>`

Pin to a specific version for production:
```yaml
image: ghcr.io/entelect-incubator/pezza-api:v1.0.0
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
services:
  api:
    image: ghcr.io/entelect-incubator/pezza-api:latest
    options: >-
      --health-cmd="curl -f http://localhost:5000/health || exit 1"
      --health-interval=10s
      --health-timeout=5s
      --health-retries=5
    ports:
      - 5000:5000
```

## Support

For API documentation and feature details, see:

- [Phase 14 - Final Solution](../.NET/Phase%2014/) - Complete API implementation
- [Phase 15 - GitHub Container Registry CI/CD](../.NET/Phase%2015/) - Publishing pipeline
- [Design Patterns Hub](./Design-Patterns/) - Architecture and best practices
