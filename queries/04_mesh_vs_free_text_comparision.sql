-- MeSH Term vs. Free-Text Condition Matching Comparison
-- Purpose: Compare standardized MeSH-based classification against free-text 
-- keyword matching for identifying cancer-related trials, to assess which 
-- method is more reliable for classification tasks

-- Method 1: Standardized MeSH term matching
SELECT COUNT(DISTINCT mesh_term) AS unique_mesh_terms
FROM browse_conditions
WHERE mesh_term ILIKE '%neoplasm%';
-- Result: 169 unique MeSH terms

SELECT COUNT(mesh_term) AS total_mesh_matches
FROM browse_conditions
WHERE mesh_term ILIKE '%neoplasm%';
-- Result: 515,648 total trial-condition matches

-- Method 2: Free-text condition name matching
SELECT COUNT(DISTINCT downcase_name) AS unique_freetext_names
FROM conditions
WHERE downcase_name ~* 'cancer|carcinoma|tumor';
-- Result: 12,424 unique free-text name variants

SELECT COUNT(downcase_name) AS total_freetext_matches
FROM conditions
WHERE downcase_name ~* 'cancer|carcinoma|tumor';
-- Result: 132,375 total trial-condition matches

-- Key Finding:
-- Free-text keyword matching identified 132,375 cancer-related trial-condition 
-- entries, while standardized MeSH term classification identified 515,648 — 
-- nearly 4x more matches. This is because the same condition can be written 
-- in 12,424 different free-text variations (typos, abbreviations, phrasing 
-- differences), while MeSH consolidates these into just 169 controlled terms. 
-- This demonstrates why controlled vocabularies are preferred over free-text 
-- search for reliable classification in clinical/healthcare data pipelines.