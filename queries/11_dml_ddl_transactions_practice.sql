-- DML / DDL / Transactions Practice
-- Purpose: Practice INSERT, UPDATE, DELETE, ALTER TABLE, and transaction 
-- control (BEGIN/COMMIT/ROLLBACK) using a throwaway table, separate from 
-- the real AACT data (never run DML/DDL practice directly on ctgov.* tables)

-- ============================================
-- CREATE a safe practice table
-- ============================================
CREATE TABLE practice_trials (
    id SERIAL PRIMARY KEY,
    trial_name VARCHAR(100),
    phase VARCHAR(20),
    status VARCHAR(20),
    participant_count INT
);

-- ============================================
-- INSERT rows
-- ============================================
INSERT INTO practice_trials (trial_name, phase, status, participant_count)
VALUES 
  ('Trial A', 'PHASE1', 'COMPLETED', 50),
  ('Trial B', 'PHASE2', 'RECRUITING', 120),
  ('Trial C', 'PHASE3', 'TERMINATED', 300);

-- ============================================
-- UPDATE a row
-- Note: string values need single quotes, not double quotes 
-- (double quotes are for identifiers like column/table names)
-- ============================================
UPDATE practice_trials
SET status = 'COMPLETED', participant_count = 130
WHERE trial_name = 'Trial B';

-- ============================================
-- ALTER TABLE: add a new column
-- ============================================
ALTER TABLE practice_trials
ADD COLUMN start_date DATE;

-- ALTER TABLE can also rename a column, useful for fixing typos
-- (used this after accidentally typing "dtart_date" instead of "start_date")
-- ALTER TABLE practice_trials RENAME COLUMN dtart_date TO start_date;

-- ============================================
-- INSERT using CURRENT_DATE (no quotes -- it's a keyword, not a string)
-- ============================================
INSERT INTO practice_trials (trial_name, phase, status, participant_count, start_date)
VALUES ('Trial F', 'PHASE2', 'RECRUITING', 75, CURRENT_DATE);

-- ============================================
-- DELETE a specific row (always use WHERE, or every row gets deleted)
-- ============================================
DELETE FROM practice_trials
WHERE status IS NULL;

-- ============================================
-- TRANSACTIONS: BEGIN / ROLLBACK / COMMIT
-- ============================================
-- Everything after BEGIN is provisional until COMMIT (saved permanently)
-- or ROLLBACK (undone completely, back to state before BEGIN).
-- If ANY statement inside a transaction errors, the whole transaction is
-- aborted -- Postgres will refuse further commands until you ROLLBACK,
-- even commands unrelated to the error.

BEGIN;

INSERT INTO practice_trials (trial_name, phase, status, participant_count)
VALUES ('Trial G', 'PHASE1', 'RECRUITING', 40);

-- SAVEPOINT lets you undo part of a transaction without rolling back
-- everything since BEGIN:
-- SAVEPOINT sp1;
-- INSERT INTO practice_trials (trial_name) VALUES ('Trial H');
-- ROLLBACK TO sp1;  -- undoes only Trial H, keeps Trial G

COMMIT;  -- saves Trial G permanently

-- ============================================
-- Final check
-- ============================================
SELECT * FROM practice_trials;

-- ============================================
-- Cleanup (drop the practice table once done)
-- DROP TABLE removes the entire table + data, unlike DELETE which only
-- removes rows and leaves the (now empty) table structure intact
-- ============================================
-- DROP TABLE IF EXISTS practice_trials;