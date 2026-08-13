-- RANK() vs DENSE_RANK() Comparison
-- Purpose: Demonstrate the difference between RANK() and DENSE_RANK() 
-- window functions when ranking tied values, using baseline_measurements

-- Note: param_value is stored as text (character varying), which caused 
-- '.0' and '0' to rank as different values initially. param_value_num 
-- (a cleaned numeric column) resolves this -- a good example of why 
-- raw/as-submitted text fields shouldn't be trusted for numeric sorting.

SELECT param_type, param_value_num,
  RANK() OVER (PARTITION BY param_type ORDER BY param_value_num DESC) AS rank_result,
  DENSE_RANK() OVER (PARTITION BY param_type ORDER BY param_value_num DESC) AS dense_rank_result
FROM baseline_measurements
WHERE param_type = 'COUNT_OF_PARTICIPANTS' AND param_value_num IS NOT NULL
ORDER BY param_value_num DESC
LIMIT 20;

-- Key takeaway:
-- RANK() assigns the same rank to tied rows, then SKIPS subsequent rank 
-- numbers to account for the ties (e.g., 1, 1, 1, 4).
-- DENSE_RANK() assigns the same rank to ties but does NOT skip -- ranks 
-- stay consecutive (e.g., 1, 1, 1, 2).
-- Use RANK() when you want ties to affect downstream ranking (e.g., 
-- "top 10" where a 4-way tie for #1 means the next rank is #5).
-- Use DENSE_RANK() when you want a clean, consecutive rank count 
-- regardless of how many ties occurred.