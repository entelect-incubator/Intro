# Pezza PostgreSQL Database Image
# Pre-configured with schema and sample data for all Incubators

FROM postgres:16-alpine

# Set environment variables
ENV POSTGRES_DB=pezza
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres

# Copy schema and initialization script
COPY postgres-schema.sql /docker-entrypoint-initdb.d/01-schema.sql

# Expose PostgreSQL port
EXPOSE 5432

# Health check
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD pg_isready -U postgres -d pezza || exit 1

LABEL org.opencontainers.image.source="https://github.com/entelect-incubator/Incubator"
LABEL org.opencontainers.image.description="Pezza PostgreSQL database with sample schema and data for Incubators"
LABEL org.opencontainers.image.version="1.0.0"
