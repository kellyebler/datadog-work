# PostgreSQL Verification Script

A utility script to verify that the Datadog user has the correct permissions for Database Monitoring (DBM) on PostgreSQL.

## Files

- `verify.sh` - Interactive script to test Datadog user permissions

## Usage

```bash
chmod +x verify.sh
./verify.sh
```

The script will prompt for:
- `DB_HOST` - PostgreSQL host endpoint
- `DB_NAME` - Database name to test

## What It Tests

The script verifies read access to three critical system views:

1. **pg_stat_database** - Database-level statistics
2. **pg_stat_activity** - Current database connections and queries
3. **pg_stat_statements** - Query performance statistics (requires extension)

## Prerequisites

- `psql` client installed
- Network access to the PostgreSQL host
- `datadog` user created with appropriate permissions

## Setting Up the Datadog User

For RDS PostgreSQL, follow the [Datadog DBM setup guide](https://docs.datadoghq.com/database_monitoring/setup_postgres/rds/).

## Related Configuration

See `../agent/conf.d/postgres.d/conf.yaml` for the corresponding agent configuration.
