-- Regulatory Classification Overview
-- Purpose: Understand how many studies fall into key FDA regulatory categories

SELECT
    COUNT(*) FILTER (WHERE is_fda_regulated_drug = TRUE) AS fda_regulated_drug,
    COUNT(*) FILTER (WHERE is_unapproved_device = TRUE) AS unapproved_device,
    COUNT(*) FILTER (WHERE is_fda_regulated_device = TRUE) AS fda_regulated_device,
    COUNT(*) FILTER (WHERE is_ppsd = TRUE) AS ppsd,
    COUNT(*) FILTER (WHERE is_us_export = TRUE) AS us_export
FROM studies;

-- Result (as of [today's date], out of 595,625 total studies):
-- fda_regulated_drug: 53,893
-- unapproved_device: 5,185
-- fda_regulated_device: 20,246
-- ppsd: 22
-- us_export: 15,323