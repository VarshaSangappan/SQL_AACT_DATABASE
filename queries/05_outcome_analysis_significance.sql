-- Outcome Analysis: Statistical Methods & Significance in Oncology Trials
-- Purpose: Examine what statistical methods are used in reported trial outcomes,
-- and compare oncology-specific significance rates against the database-wide rate

-- Step 1: Reusable view for oncology trial identification (via MeSH classification)
CREATE VIEW oncology_trials AS
SELECT DISTINCT s.nct_id
FROM studies s
JOIN browse_conditions bc ON s.nct_id = bc.nct_id
WHERE bc.mesh_term ILIKE '%neoplasm%';

-- Step 2: Most common statistical methods used across all reported outcomes
SELECT method, COUNT(*) AS usage_count
FROM outcome_analyses
WHERE method IS NOT NULL
GROUP BY method
ORDER BY usage_count DESC
LIMIT 10;
-- Top methods: ANCOVA (43,960), Mixed Models Analysis (39,579), 
-- t-test 2-sided (21,558), ANOVA (20,299), Cochran-Mantel-Haenszel (14,067)

-- Step 3: Database-wide significance rate (all trials)
SELECT 
  COUNT(*) AS total_analyses,
  COUNT(*) FILTER (WHERE p_value < 0.05) AS significant_results,
  ROUND(100.0 * COUNT(*) FILTER (WHERE p_value < 0.05) / COUNT(*), 1) AS pct_significant
FROM outcome_analyses
WHERE p_value IS NOT NULL;
-- Result: 264,202 total analyses | 106,804 significant | 40.4% significance rate

-- Step 4: Oncology-specific significance rate (using the view)
SELECT
  COUNT(*) AS total_oncology_analyses,
  COUNT(*) FILTER (WHERE oa.p_value < 0.05) AS significant_results,
  ROUND(AVG(oa.p_value)::numeric, 4) AS avg_p_value
FROM outcome_analyses oa
JOIN oncology_trials ot ON oa.nct_id = ot.nct_id
WHERE oa.p_value IS NOT NULL;
-- Result: 23,129 total oncology analyses | 7,949 significant (34.4%) | avg p-value: 0.3035

-- Key Finding:
-- Oncology trials show a lower statistical significance rate (34.4%) compared to
-- the database-wide rate (40.4%) -- a ~6 percentage point gap. This is consistent 
-- with the earlier finding that oncology trials have a higher termination/withdrawal 
-- rate, suggesting oncology research may face greater challenges in demonstrating 
-- statistically significant treatment effects, possibly due to disease heterogeneity, 
-- smaller effect sizes, or trials stopping before reaching definitive conclusions.