#!/bin/bash
# Author: Kelly Ebler
# This script will check to ensure that the datadog user has the correct permissions to access a postgresql database
# Command taken from https://docs.datadoghq.com/database_monitoring/setup_postgres/rds/?tab=postgres15#verify


read -p "DB_HOST: " DB_HOST
read -p "DB_NAME: " DB_NAME

psql -h $DB_HOST -U datadog $DB_NAME -A \
  -c "select * from pg_stat_database limit 1;" \
  && echo -e "\e[0;32m$DB_NAME connection - OK\e[0m" \
  || echo -e "\e[0;31mCannot connect to $DB_NAME\e[0m"
psql -h $DB_HOST -U datadog $DB_NAME -A \
  -c "select * from pg_stat_activity limit 1;" \
  && echo -e "\e[0;32m$DB_NAME pg_stat_activity read OK\e[0m" \
  || echo -e "\e[0;31mCannot read from pg_stat_activity\e[0m"
psql -h $DB_HOST -U datadog $DB_NAME -A \
  -c "select * from pg_stat_statements limit 1;" \
  && echo -e "\e[0;32m$DB_NAME pg_stat_statements read OK\e[0m" \
  || echo -e "\e[0;31mCannot read from pg_stat_statements\e[0m"
