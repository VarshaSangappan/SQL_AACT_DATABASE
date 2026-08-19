-- Sponsors Active Across All Trial Phases (Oncology)
-- Purpose: Identify sponsors who have run oncology trials in all four phases
-- (Phase 1 through Phase 4) -- i.e., sponsors with a full clinical development
-- pipeline in oncology, not just a single-phase presence

-- Technique: two chained CTEs + HAVING on a DISTINCT count
-- 1st CTE (onco_phase): distinct sponsor/phase pairs for oncology trials
-- 2nd CTE (phase_spons): counts distinct phases per sponsor, keeping only
--    sponsors where that count equals 4 (i.e., present in every phase)

WITH onco_phase AS (
    SELECT DISTINCT
        sp.name AS sponsor_name,
        s.phase
    FROM studies s
    JOIN oncology_trials o
        ON s.nct_id = o.nct_id
    JOIN sponsors sp
        ON s.nct_id = sp.nct_id
    WHERE s.phase IN ('PHASE1', 'PHASE2', 'PHASE3', 'PHASE4')
),
phase_spons AS (
    SELECT
        sponsor_name,
        COUNT(DISTINCT phase) AS phase_count
    FROM onco_phase
    GROUP BY sponsor_name
    HAVING COUNT(DISTINCT phase) = 4
)
SELECT sponsor_name
FROM phase_spons
ORDER BY sponsor_name;

-- Key finding:  484 sponsors found who sponsored for whole trial
-- trials across the full development pipeline (Phase 1 through Phase 4),
-- not just early-stage or late-stage work.