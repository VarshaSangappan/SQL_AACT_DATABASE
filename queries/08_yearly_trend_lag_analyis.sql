-- Year-over-Year Trend Analysis: Pending Results Events
-- Purpose: Track how pending clinical trial results reporting has changed 
-- year over year, using LAG() to compare each year against the previous one

-- Data quality note: event_date has some NULL values (401 rows), which 
-- initially grouped into a meaningless "year = NULL" bucket that distorted 
-- the trend. Filtered these out with WHERE event_date IS NOT NULL, since 
-- undated events don't belong in a year-over-year comparison.

WITH yearly_counts AS (
  SELECT 
    EXTRACT(YEAR FROM event_date) AS year,
    COUNT(*) AS event_count
  FROM pending_results
  WHERE event_date IS NOT NULL
  GROUP BY EXTRACT(YEAR FROM event_date)
)
SELECT 
  year,
  event_count,
  LAG(event_count) OVER (ORDER BY year) AS previous_year_count,
  event_count - LAG(event_count) OVER (ORDER BY year) AS change_from_last_year
FROM yearly_counts
ORDER BY year;

-- Key Finding:
-- Pending results events have grown substantially over time, with sharp 
-- acceleration starting in 2023: 
--   2022: 1,861 -> 2023: 2,923 (+1,062)
--   2023: 2,923 -> 2024: 4,080 (+1,157)
--   2024: 4,080 -> 2025: 4,492 (+412)
--   2025: 4,492 -> 2026: 4,949 (+457)
-- This growth likely reflects increased regulatory scrutiny/enforcement 
-- of results-reporting requirements in recent years, and demonstrates 
-- LAG() as a practical tool for year-over-year trend analysis.