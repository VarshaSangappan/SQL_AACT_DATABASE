-- Data Quality Check: Missing values in key date/status fields
-- Purpose: Assess completeness of the studies table before deeper analysis

SELECT
  COUNT(*) AS total_studies,
  COUNT(*) - COUNT(results_first_submitted_date) AS missing_result_date,
  COUNT(*) - COUNT(verification_date) AS not_verified,
  COUNT(*) - COUNT(completion_date) AS not_completed
FROM studies;

-- Result (as of [today's date]):
-- total_studies: 595,625
-- missing_result_date: 516,289 (~87% never reported results)
-- not_verified: 981
-- not_completed: 16,685