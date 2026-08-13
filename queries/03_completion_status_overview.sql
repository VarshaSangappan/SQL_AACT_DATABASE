-- Completion Status Overview: Oncology Trials (with percentages)
-- Purpose: Understand the distribution of trial outcomes for cancer-related trials,
-- expressed as both raw counts and percentage of total oncology trials

SELECT 
  overall_status, 
  COUNT(*) AS trial_count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS percentage
FROM studies s
JOIN conditions c ON s.nct_id = c.nct_id
WHERE c.downcase_name ILIKE '%cancer%'
   OR c.downcase_name ILIKE '%carcinoma%'
   OR c.downcase_name ILIKE '%tumor%'
   OR c.downcase_name ILIKE '%neoplasm%'
GROUP BY overall_status
ORDER BY trial_count DESC;

-- Results (147,568 total oncology-related studies):
-- COMPLETED:               60,156 (40.8%)
-- RECRUITING:               25,994 (17.6%)
-- UNKNOWN:                  19,062 (12.9%)
-- TERMINATED:               14,687 (10.0%)
-- ACTIVE_NOT_RECRUITING:    13,301 (9.0%)
-- NOT_YET_RECRUITING:        7,011 (4.8%)
-- WITHDRAWN:                 5,489 (3.7%)
-- (remaining categories: <1% each)

-- Key insight: TERMINATED + WITHDRAWN = 13.7% of oncology trials,
-- notably higher than the ~8.5% termination/withdrawal rate across 
-- all studies in the database — consistent with oncology trials 
-- often stopping early due to efficacy, futility, or toxicity findings.