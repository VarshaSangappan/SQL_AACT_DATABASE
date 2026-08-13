-- Year-over-Year Trend Analysis: Study Verification Dates (using LEAD)
-- Purpose: Track how many trials are verified each year and compare each 
-- year to the following year, using LEAD() to look forward in the sequence

-- Data quality finding: an initial unfiltered run showed a verification 
-- year of 1920 for NCT00056849 ("Genetic Determinants of Ankylosing 
-- Spondylitis Severity", status: COMPLETED) -- clearly a data entry error, 
-- since ClinicalTrials.gov registry began in 2000. Almost certainly a 
-- typo (2020 entered as 1920). Filtered out any year before 2000 to 
-- exclude this and similar erroneous dates.

WITH verify_years AS (
  SELECT 
    EXTRACT(YEAR FROM verification_date) AS verify_year,
    COUNT(*) AS trial_count
  FROM studies
  WHERE verification_date IS NOT NULL 
    AND EXTRACT(YEAR FROM verification_date) >= 2000
  GROUP BY EXTRACT(YEAR FROM verification_date)
)
SELECT 
  verify_year,
  trial_count,
  LEAD(trial_count) OVER (ORDER BY verify_year) AS next_year_count,
  LEAD(trial_count) OVER (ORDER BY verify_year) - trial_count AS change_to_next_year
FROM verify_years
ORDER BY verify_year;

-- Key takeaway: LEAD() mirrors LAG() -- it looks forward to the next row 
-- instead of back. Same rule applies: aggregate first (GROUP BY into one 
-- row per year), then apply LEAD() on the aggregated result, with 
-- ORDER BY inside the OVER() clause controlling the actual sequence used 
-- for the calculation (separate from any outer ORDER BY used for display).