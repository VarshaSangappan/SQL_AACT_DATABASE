-- Indexing & EXPLAIN ANALYZE Practice
-- NOTE: This file is for practice/learning purposes only -- exploring how
-- indexes affect query performance on the AACT database. It is not part
-- of the core oncology analysis; it's here to document hands-on learning
-- about how Postgres actually executes queries.

-- EXPLAIN ANALYZE shows Postgres's real execution plan and actual timing
-- for a query. It's a diagnostic tool only -- it doesn't speed anything up
-- itself, it just reveals what Postgres is already doing. An index, once
-- created, speeds up matching queries automatically and permanently --
-- no special syntax is needed to "use" it going forward.

-- ============================================
-- Case 1: Column WITH an existing index (overall_status)
-- ============================================
EXPLAIN ANALYZE
SELECT * FROM studies WHERE overall_status = 'TERMINATED';
-- Result: Bitmap Index Scan used. Index lookup itself was fast (~13ms),
-- but total execution was ~1422ms because SELECT * pulls every column
-- (width=1665 bytes/row) for 34,011 matching rows.

EXPLAIN ANALYZE
SELECT nct_id FROM studies WHERE overall_status = 'TERMINATED';
-- Result: same index used, but execution dropped to ~210ms just by
-- selecting one column instead of all of them (width=12 bytes/row).
-- Lesson: SELECT * has a real, measurable performance cost on wide
-- tables -- always select only the columns you actually need.

-- ============================================
-- Case 2: Wildcard search -- index CANNOT help here
-- ============================================
EXPLAIN ANALYZE
SELECT nct_id FROM studies WHERE source ILIKE '%hospital%';
-- Result: Seq Scan (~1477ms), scanning all 595,625 rows and discarding
-- 482,678 non-matches.

CREATE INDEX idx_studies_source ON studies (source);

EXPLAIN ANALYZE
SELECT nct_id FROM studies WHERE source ILIKE '%hospital%';
-- Result: STILL a Seq Scan, no improvement (~1564ms). A standard B-tree
-- index cannot be used for a "%contains%" pattern with wildcards on both
-- sides, since there's no way to look up a substring that could appear
-- anywhere in the text. Would need a different index type (e.g. GIN with
-- trigram support) to speed this up.

DROP INDEX idx_studies_source;  -- cleanup: proven not useful for this query

-- ============================================
-- Case 3: Exact match on a moderately selective column (enrollment)
-- ============================================
EXPLAIN ANALYZE
SELECT nct_id FROM studies WHERE enrollment = 100;
-- Result: Parallel Seq Scan (~223ms). Postgres was already using 2
-- parallel workers to help, so the "unindexed" baseline wasn't very slow.

CREATE INDEX idx_studies_enrollment ON studies (enrollment);

EXPLAIN ANALYZE
SELECT nct_id FROM studies WHERE enrollment = 100;
-- Result: Bitmap Index Scan used, ~158ms -- about 30% faster, not a
-- dramatic speedup. 17,736 of 595,625 rows matched (~3%), which is a
-- fairly large fraction -- indexes give the biggest wins on highly
-- selective queries (a small % of the table), not moderate ones.

DROP INDEX idx_studies_enrollment;  -- cleanup after testing

-- ============================================
-- Key takeaways
-- ============================================
-- 1. Indexes speed up FINDING rows, not necessarily fetching them --
--    SELECT * still costs you even with a perfect index.
-- 2. Standard B-tree indexes don't help "%contains%" wildcard searches.
-- 3. The performance gain from an index depends on selectivity (what
--    fraction of the table matches) and what Postgres can already do
--    (e.g. parallel workers) to compensate -- "just add an index" is
--    not always a big win, and testing with EXPLAIN ANALYZE is the only
--    reliable way to know.