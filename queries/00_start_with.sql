-- 00_start_with.sql
-- Setup & exploration reference for the AACT database
-- Run these once after restoring the database, before the numbered query files

-- ============================================
-- SETUP (run these from Command Prompt, not psql)
-- ============================================

-- Create the local database
-- createdb -U postgres aact

-- Restore the AACT snapshot into it (after downloading postgres.dmp from
-- https://aact.ctti-clinicaltrials.org/downloads)
-- pg_restore -U postgres -e -v -O -x -d aact --no-owner path/to/postgres.dmp

-- Connect to the database
-- psql -U postgres -d aact


-- ============================================
-- EXPLORATION (run these inside psql)
-- ============================================

-- List all databases on this Postgres instance
\l

-- List all schemas in the current database
-- AACT data lives in the "ctgov" schema, not "public"
\dn

-- List all tables inside the ctgov schema
\dt ctgov.*

-- Describe a specific table's columns, types, and nullability
\d ctgov.studies

-- See columns + data types for any table via information_schema
-- (useful for scripting/generating queries automatically)
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'ctgov' AND table_name = 'studies'
ORDER BY ordinal_position;

-- Search for a column name across ALL tables (handy when you're not sure
-- which table a field like "phase" actually lives in)
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_schema = 'ctgov'
AND column_name ILIKE '%phase%';

-- Get approximate row counts for every table (fast, uses internal stats
-- instead of scanning each table)
SELECT relname AS table_name, n_live_tup AS approx_row_count
FROM pg_stat_user_tables
WHERE schemaname = 'ctgov'
ORDER BY n_live_tup DESC
LIMIT 15;

-- Set the search path so you don't need to prefix every query with "ctgov."
-- Run this once per session
SET search_path TO ctgov;

-- Fix encoding errors caused by non-English characters in some free-text
-- fields (e.g., condition names with fullwidth punctuation)
SET client_encoding TO 'UTF8';


-- ============================================
-- NOTES
-- ============================================
-- - All project data lives in the "ctgov" schema (595,625 studies as of
--   the snapshot used here).
-- - psql meta-commands (starting with \) are not SQL -- no semicolon needed,
--   and they run instantly without querying the database.
-- - If a query hangs waiting for more input (prompt shows "aact-#" or
--   "aact(#" instead of "aact=#"), it usually means a statement wasn't
--   closed with a semicolon. Type ; and press Enter to reset.
