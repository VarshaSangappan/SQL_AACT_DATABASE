-- Data Completeness Audit: calculated_values table
-- Purpose: Systematically assess null rates across all columns in the 
-- calculated_values table using metadata-driven query generation, 
-- to identify which fields are reliably populated vs. largely missing

-- Technique: First queried information_schema.columns to auto-generate
-- COUNT(*) FILTER (WHERE col IS NULL) snippets for every column, 
-- then manually assembled them into a single audit query using a CTE
-- + UNION ALL (pivoting wide results into long/row format for easy reading)

WITH total_counts AS (
  SELECT
    COUNT(*) FILTER (WHERE number_of_other_outcomes_to_measure IS NULL) AS c1,
    COUNT(*) FILTER (WHERE number_of_primary_outcomes_to_measure IS NULL) AS c2,
    COUNT(*) FILTER (WHERE number_of_secondary_outcomes_to_measure IS NULL) AS c3,
    COUNT(*) FILTER (WHERE id IS NULL) AS c4,
    COUNT(*) FILTER (WHERE number_of_facilities IS NULL) AS c5,
    COUNT(*) FILTER (WHERE number_of_nsae_subjects IS NULL) AS c6,
    COUNT(*) FILTER (WHERE number_of_sae_subjects IS NULL) AS c7,
    COUNT(*) FILTER (WHERE registered_in_calendar_year IS NULL) AS c8,
    COUNT(*) FILTER (WHERE nlm_download_date IS NULL) AS c9,
    COUNT(*) FILTER (WHERE actual_duration IS NULL) AS c10,
    COUNT(*) FILTER (WHERE were_results_reported IS NULL) AS c11,
    COUNT(*) FILTER (WHERE months_to_report_results IS NULL) AS c12,
    COUNT(*) FILTER (WHERE has_us_facility IS NULL) AS c13,
    COUNT(*) FILTER (WHERE has_single_facility IS NULL) AS c14,
    COUNT(*) FILTER (WHERE minimum_age_num IS NULL) AS c15,
    COUNT(*) FILTER (WHERE maximum_age_num IS NULL) AS c16,
    COUNT(*) FILTER (WHERE nct_id IS NULL) AS c17,
    COUNT(*) FILTER (WHERE minimum_age_unit IS NULL) AS c18,
    COUNT(*) FILTER (WHERE maximum_age_unit IS NULL) AS c19
  FROM calculated_values
),
total_rows AS (
  SELECT COUNT(*) AS total_values FROM calculated_values
)
SELECT
  column_name,
  null_count,
  total_values,
  (total_values - null_count) AS total_without_null,
  ROUND(100.0 * null_count / total_values, 1) AS pct_null
FROM (
  SELECT 'number_of_other_outcomes_to_measure' AS column_name, c1 AS null_count FROM total_counts
  UNION ALL SELECT 'number_of_primary_outcomes_to_measure', c2 FROM total_counts
  UNION ALL SELECT 'number_of_secondary_outcomes_to_measure', c3 FROM total_counts
  UNION ALL SELECT 'id', c4 FROM total_counts
  UNION ALL SELECT 'number_of_facilities', c5 FROM total_counts
  UNION ALL SELECT 'number_of_nsae_subjects', c6 FROM total_counts
  UNION ALL SELECT 'number_of_sae_subjects', c7 FROM total_counts
  UNION ALL SELECT 'registered_in_calendar_year', c8 FROM total_counts
  UNION ALL SELECT 'nlm_download_date', c9 FROM total_counts
  UNION ALL SELECT 'actual_duration', c10 FROM total_counts
  UNION ALL SELECT 'were_results_reported', c11 FROM total_counts
  UNION ALL SELECT 'months_to_report_results', c12 FROM total_counts
  UNION ALL SELECT 'has_us_facility', c13 FROM total_counts
  UNION ALL SELECT 'has_single_facility', c14 FROM total_counts
  UNION ALL SELECT 'minimum_age_num', c15 FROM total_counts
  UNION ALL SELECT 'maximum_age_num', c16 FROM total_counts
  UNION ALL SELECT 'nct_id', c17 FROM total_counts
  UNION ALL SELECT 'minimum_age_unit', c18 FROM total_counts
  UNION ALL SELECT 'maximum_age_unit', c19 FROM total_counts
) t
CROSS JOIN total_rows
ORDER BY null_count DESC;

-- Key Findings (out of 595,625 total records):
-- - nlm_download_date: 100% null -- appears fully deprecated/unused
-- - number_of_sae_subjects (serious adverse events): 92.9% null -- 
--   major transparency gap in safety outcome reporting
-- - number_of_other_outcomes_to_measure: 91.4% null
-- - months_to_report_results: 86.7% null -- consistent with earlier 
--   finding that most trials never report results
-- - 5 columns are fully populated (0% null): id, nct_id, 
--   were_results_reported, registered_in_calendar_year, number_of_facilities