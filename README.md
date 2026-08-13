# SQL_AACT_DATABASE — Oncology Clinical Trials Analysis

I built this project to practice SQL on a real, large-scale relational database rather than a small toy dataset. I used AACT (Aggregate Analysis of ClinicalTrials.gov) — a public database that mirrors all the data submitted to ClinicalTrials.gov — and focused specifically on oncology (cancer) trials.

The database has ~600,000 studies spread across 50+ linked tables (sponsors, conditions, outcomes, facilities, etc.), so working with it meant actually dealing with joins across tables, messy/missing data, and inconsistent free-text entries — the kind of problems you don't run into with a clean single CSV.

## Why AACT, why oncology

I'm coming from a bioinformatics background and I'm targeting Data Scientist / ML Engineer roles in pharma and biotech, so I wanted a SQL project that would actually be relevant to that — not just generic practice data. AACT is a real dataset used in clinical operations and pharma analytics, and it's public with no signup required for the static snapshots, which made it easy to get started quickly.

I narrowed the scope to oncology trials specifically, rather than trying to cover everything, mostly because a focused analysis with a clear angle felt more useful to build than a broad, shallow one.

## Approch

Set up PostgreSQL locally, restored the AACT snapshot (~600K studies, tens of millions of rows across all tables), and worked through a series of queries — starting with basic exploration (what tables exist, what's missing, what the data actually looks like) and building up to joins, CTEs, and window functions.

I ran into and had to debug several real issues along the way rather than just writing clean queries against clean data:
- Encoding errors from non-English characters in condition names
- A column storing numbers as text (`param_value` vs. `param_value_num`), which silently produced wrong sort order until I caught it
- An outlier with ~20 million "participants" that turned out to be legitimate (a population-registry study), not bad data — but only after I checked
- A verification date of `1920-01-31` on a modern completed trial, which was clearly a typo for 2020

I think these debugging moments are honestly more representative of real data work than the clean queries are, so I documented them directly in the query files rather than smoothing them over.

## Key Findings

- **Oncology trials terminate or get withdrawn more often than average** — about 13.7% of oncology trials, versus ~8.5% across the full database. Makes sense given trials often stop early for efficacy, futility, or safety reasons.
- **MeSH-based classification found ~4x more relevant trials than free-text keyword search.** Searching condition names for "cancer/carcinoma/tumor" found ~132K matches; using the standardized MeSH term system found ~516K. This was a good reminder of why controlled vocabularies matter for real data classification, not just SQL syntax practice.
- **Statistically significant results are less common in oncology outcomes** — 34.4% vs. 40.4% database-wide.
- **A lot of safety data is missing.** ~93% of studies have no recorded count of serious adverse event subjects. That's a real transparency gap, not just a quirk of this dataset.
- **Reporting activity has picked up sharply since 2023** — pending-results events nearly tripled between 2022 and 2024, which is worth a follow-up read on regulatory context if I get time.

## SQL commands used

Joins, CTEs, subqueries, views, `UNION ALL` (to pivot columns into rows), conditional aggregation with `FILTER`, and window functions — `SUM() OVER()`, `RANK()`, `DENSE_RANK()`, `LAG()`, and `LEAD()`. Full list of files below.

## Files

```
queries/
├── 00_start_with.sql
├── 01_data_quality_check.sql
├── 02_regulatory_classification_check.sql
├── 03_completion_status_overview.sql
├── 04_mesh_vs_freetext_comparison.sql
├── 05_outcome_analysis_significance.sql
├── 06_data_completeness_audit.sql
├── 07_rank_vs_dense_rank.sql
├── 08_yearly_trend_lag_analysis.sql
└── 09_lead_yoy_verification_trend.sql
```

Each file has comments explaining what the query does and what I found from it, including the data issues above.


## Note on the data

AACT keeps the data as-submitted, without cleaning it up. So missing values, inconsistent free text, and occasional entry errors (like the 1920 date) are part of the real dataset, not something introduced by me. I've tried to call these out honestly in the queries rather than filtering them out silently.

---
Varsha — M.Tech Bioinformatics, final year.
