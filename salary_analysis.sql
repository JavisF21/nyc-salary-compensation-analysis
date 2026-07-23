/*
NYC Jobs Salary Analysis
Author: Javis Foster

Purpose:
Analyze NYC Open Data job postings using PostgreSQL.
This script covers data validation, hiring activity, salary analysis,
career levels, posting trends, locations, CTEs, window functions, and views.
*/

-- =========================================================
-- SECTION 1: DATA VALIDATION
-- =========================================================

-- 1. Preview the data
SELECT *
FROM jobs
LIMIT 10;


-- 2. Count total job postings
SELECT COUNT(*) AS total_postings
FROM jobs;


-- 3. Count total columns
SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'jobs';


-- 4. Check missing salary values
SELECT
    COUNT(*) FILTER (
        WHERE "Salary Range From" IS NULL
    ) AS missing_salary_from,
    COUNT(*) FILTER (
        WHERE "Salary Range To" IS NULL
    ) AS missing_salary_to
FROM jobs;


-- 5. Check the posting date range
SELECT
    MIN("Posting Date") AS earliest_posting_date,
    MAX("Posting Date") AS latest_posting_date
FROM jobs;


-- =========================================================
-- SECTION 2: JOB POSTING OVERVIEW
-- =========================================================

-- 6. Top 10 agencies by number of job postings
SELECT
    "Agency",
    COUNT(*) AS total_postings
FROM jobs
GROUP BY "Agency"
ORDER BY total_postings DESC
LIMIT 10;


-- 7. Most common job categories
SELECT
    "Job Category",
    COUNT(*) AS total_postings
FROM jobs
WHERE "Job Category" IS NOT NULL
GROUP BY "Job Category"
ORDER BY total_postings DESC
LIMIT 10;


-- 8. Full-time versus part-time postings
SELECT
    COALESCE(
        "Full-Time/Part-Time indicator",
        'Not specified'
    ) AS employment_type,
    COUNT(*) AS total_postings
FROM jobs
GROUP BY "Full-Time/Part-Time indicator"
ORDER BY total_postings DESC;


-- 9. Job postings by career level
SELECT
    COALESCE(
        "Career Level",
        'Not specified'
    ) AS career_level,
    COUNT(*) AS total_postings
FROM jobs
GROUP BY "Career Level"
ORDER BY total_postings DESC;


-- 10. Number of available positions by agency
SELECT
    "Agency",
    SUM("# Of Positions") AS total_positions
FROM jobs
GROUP BY "Agency"
ORDER BY total_positions DESC
LIMIT 10;


-- =========================================================
-- SECTION 3: SALARY ANALYSIS
-- =========================================================

-- 11. Salary frequency breakdown
SELECT
    "Salary Frequency",
    COUNT(*) AS total_postings
FROM jobs
GROUP BY "Salary Frequency"
ORDER BY total_postings DESC;


-- 12. Average salary midpoint by salary frequency
SELECT
    "Salary Frequency",
    ROUND(
        AVG(
            ("Salary Range From" + "Salary Range To") / 2
        ),
        2
    ) AS average_salary_midpoint,
    COUNT(*) AS total_postings
FROM jobs
WHERE "Salary Range From" IS NOT NULL
  AND "Salary Range To" IS NOT NULL
GROUP BY "Salary Frequency"
ORDER BY total_postings DESC;


-- 13. Highest-paying annual job postings
SELECT
    "Business Title",
    "Agency",
    "Salary Range From",
    "Salary Range To",
    ROUND(
        ("Salary Range From" + "Salary Range To") / 2,
        2
    ) AS salary_midpoint
FROM jobs
WHERE LOWER("Salary Frequency") = 'annual'
  AND "Salary Range From" IS NOT NULL
  AND "Salary Range To" IS NOT NULL
ORDER BY salary_midpoint DESC
LIMIT 10;


-- 14. Agencies with the highest average annual salary
SELECT
    "Agency",
    ROUND(
        AVG(
            ("Salary Range From" + "Salary Range To") / 2
        ),
        2
    ) AS average_salary_midpoint,
    COUNT(*) AS annual_postings
FROM jobs
WHERE LOWER("Salary Frequency") = 'annual'
  AND "Salary Range From" IS NOT NULL
  AND "Salary Range To" IS NOT NULL
GROUP BY "Agency"
HAVING COUNT(*) >= 5
ORDER BY average_salary_midpoint DESC
LIMIT 10;


-- 15. Annual job postings grouped into salary bands
SELECT
    CASE
        WHEN ("Salary Range From" + "Salary Range To") / 2 < 50000
            THEN 'Under $50K'
        WHEN ("Salary Range From" + "Salary Range To") / 2 < 75000
            THEN '$50K-$74,999'
        WHEN ("Salary Range From" + "Salary Range To") / 2 < 100000
            THEN '$75K-$99,999'
        WHEN ("Salary Range From" + "Salary Range To") / 2 < 150000
            THEN '$100K-$149,999'
        ELSE '$150K+'
    END AS salary_band,
    COUNT(*) AS total_postings
FROM jobs
WHERE LOWER("Salary Frequency") = 'annual'
  AND "Salary Range From" IS NOT NULL
  AND "Salary Range To" IS NOT NULL
GROUP BY salary_band
ORDER BY
    MIN(
        ("Salary Range From" + "Salary Range To") / 2
    );


-- 16. Job postings by month
SELECT
    DATE_TRUNC(
        'month',
        "Posting Date"
    )::date AS posting_month,
    COUNT(*) AS total_postings
FROM jobs
WHERE "Posting Date" IS NOT NULL
GROUP BY posting_month
ORDER BY posting_month;


-- 17. Average annual salary by career level
SELECT
    COALESCE(
        "Career Level",
        'Not specified'
    ) AS career_level,
    ROUND(
        AVG(
            ("Salary Range From" + "Salary Range To") / 2
        ),
        2
    ) AS average_salary_midpoint,
    COUNT(*) AS total_postings
FROM jobs
WHERE LOWER("Salary Frequency") = 'annual'
  AND "Salary Range From" IS NOT NULL
  AND "Salary Range To" IS NOT NULL
GROUP BY "Career Level"
ORDER BY average_salary_midpoint DESC;


-- =========================================================
-- SECTION 4: ADVANCED SQL
-- =========================================================

-- 18. Highest-paying annual job within each agency
WITH ranked_jobs AS (
    SELECT
        "Agency",
        "Business Title",
        "Salary Range From",
        "Salary Range To",
        ROUND(
            ("Salary Range From" + "Salary Range To") / 2,
            2
        ) AS salary_midpoint,
        ROW_NUMBER() OVER (
            PARTITION BY "Agency"
            ORDER BY
                ("Salary Range From" + "Salary Range To") / 2 DESC
        ) AS salary_rank
    FROM jobs
    WHERE LOWER("Salary Frequency") = 'annual'
      AND "Salary Range From" IS NOT NULL
      AND "Salary Range To" IS NOT NULL
)
SELECT
    "Agency",
    "Business Title",
    "Salary Range From",
    "Salary Range To",
    salary_midpoint
FROM ranked_jobs
WHERE salary_rank = 1
ORDER BY salary_midpoint DESC;


-- 19. Locations with the most job postings
SELECT
    COALESCE(
        "Work Location",
        'Not specified'
    ) AS work_location,
    COUNT(*) AS total_postings
FROM jobs
GROUP BY "Work Location"
ORDER BY total_postings DESC
LIMIT 10;


-- =========================================================
-- SECTION 5: REUSABLE VIEW
-- =========================================================

-- 20. Create a reusable annual jobs analysis view
CREATE OR REPLACE VIEW annual_jobs_analysis AS
SELECT
    "Job ID" AS job_id,
    "Agency" AS agency,
    "Business Title" AS business_title,
    "Job Category" AS job_category,
    "Career Level" AS career_level,
    "Work Location" AS work_location,
    "Salary Range From" AS salary_minimum,
    "Salary Range To" AS salary_maximum,
    ROUND(
        ("Salary Range From" + "Salary Range To") / 2,
        2
    ) AS salary_midpoint,
    "Posting Date" AS posting_date,
    "Posting Updated" AS posting_updated
FROM jobs
WHERE LOWER("Salary Frequency") = 'annual'
  AND "Salary Range From" IS NOT NULL
  AND "Salary Range To" IS NOT NULL;


-- 21. Preview the annual jobs analysis view
SELECT *
FROM annual_jobs_analysis
LIMIT 10;
