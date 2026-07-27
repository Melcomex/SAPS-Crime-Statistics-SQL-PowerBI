-- ============================================================
-- SOUTH AFRICA CRIME STATISTICS ANALYSIS (2005-2016)
-- Tool: MySQL Workbench 8.0
-- Author: Welcome Khayeni Molefe
-- GitHub: github.com/Melcomex
-- Dataset: South Africa Crime Statistics (Kaggle)
-- ============================================================


-- ============================================================
-- STAGE 1: DATABASE SETUP
-- ============================================================

CREATE DATABASE IF NOT EXISTS saps_crime_db;
USE saps_crime_db;

-- Tables imported via MySQL Workbench Table Data Import Wizard:
-- 1. crime_stats         (17,020 rows)
-- 2. province_population (9 rows)


-- ============================================================
-- STAGE 2: DATA EXPLORATION
-- ============================================================

SELECT * FROM crime_stats LIMIT 10;
SELECT * FROM province_population;
SELECT COUNT(*) AS total_rows FROM crime_stats;
SELECT COUNT(DISTINCT Province) AS total_provinces FROM crime_stats;
SELECT COUNT(DISTINCT Station) AS total_stations FROM crime_stats;
SELECT COUNT(DISTINCT Category) AS total_categories FROM crime_stats;


-- ============================================================
-- STAGE 3: DATA QUALITY CHECKS
-- ============================================================

-- Check for missing/blank values
SELECT
  SUM(CASE WHEN Province = '' OR Province IS NULL THEN 1 ELSE 0 END) AS missing_province,
  SUM(CASE WHEN Station = '' OR Station IS NULL THEN 1 ELSE 0 END) AS missing_station,
  SUM(CASE WHEN Category = '' OR Category IS NULL THEN 1 ELSE 0 END) AS missing_category
FROM crime_stats;

-- Check for duplicate rows
SELECT Province, Station, Category, COUNT(*) AS count
FROM crime_stats
GROUP BY Province, Station, Category
HAVING COUNT(*) > 1;

-- Check for all-zero rows
SELECT COUNT(*) AS all_zeros
FROM crime_stats
WHERE `2005-2006` = 0 AND `2006-2007` = 0 AND `2007-2008` = 0
  AND `2008-2009` = 0 AND `2009-2010` = 0 AND `2010-2011` = 0
  AND `2011-2012` = 0 AND `2012-2013` = 0 AND `2013-2014` = 0
  AND `2014-2015` = 0 AND `2015-2016` = 0;

-- Result: Dataset is clean - no missing values, no duplicates, no all-zero rows


-- ============================================================
-- STAGE 4: DATA ANALYSIS
-- ============================================================

-- Query 1: Total Crimes by Province
SELECT Province,
       SUM(`2005-2006` + `2006-2007` + `2007-2008` + `2008-2009` +
           `2009-2010` + `2010-2011` + `2011-2012` + `2012-2013` +
           `2013-2014` + `2014-2015` + `2015-2016`) AS total_crimes
FROM crime_stats
GROUP BY Province
ORDER BY total_crimes DESC;

-- Query 2: Most Common Crime Categories Nationally
SELECT Category,
       SUM(`2005-2006` + `2006-2007` + `2007-2008` + `2008-2009` +
           `2009-2010` + `2010-2011` + `2011-2012` + `2012-2013` +
           `2013-2014` + `2014-2015` + `2015-2016`) AS total_crimes
FROM crime_stats
GROUP BY Category
ORDER BY total_crimes DESC;

-- Query 3: Top 10 Most Active Police Stations
SELECT Station, Province,
       SUM(`2005-2006` + `2006-2007` + `2007-2008` + `2008-2009` +
           `2009-2010` + `2010-2011` + `2011-2012` + `2012-2013` +
           `2013-2014` + `2014-2015` + `2015-2016`) AS total_crimes
FROM crime_stats
GROUP BY Station, Province
ORDER BY total_crimes DESC
LIMIT 10;

-- Query 4: National Crime Trend Year by Year
SELECT '2005-2006' AS year, SUM(`2005-2006`) AS total_crimes FROM crime_stats
UNION ALL SELECT '2006-2007', SUM(`2006-2007`) FROM crime_stats
UNION ALL SELECT '2007-2008', SUM(`2007-2008`) FROM crime_stats
UNION ALL SELECT '2008-2009', SUM(`2008-2009`) FROM crime_stats
UNION ALL SELECT '2009-2010', SUM(`2009-2010`) FROM crime_stats
UNION ALL SELECT '2010-2011', SUM(`2010-2011`) FROM crime_stats
UNION ALL SELECT '2011-2012', SUM(`2011-2012`) FROM crime_stats
UNION ALL SELECT '2012-2013', SUM(`2012-2013`) FROM crime_stats
UNION ALL SELECT '2013-2014', SUM(`2013-2014`) FROM crime_stats
UNION ALL SELECT '2014-2015', SUM(`2014-2015`) FROM crime_stats
UNION ALL SELECT '2015-2016', SUM(`2015-2016`) FROM crime_stats;

-- Query 5: Crime Rate Per 100,000 People by Province (JOIN)
SELECT
    c.Province,
    SUM(`2005-2006` + `2006-2007` + `2007-2008` + `2008-2009` +
        `2009-2010` + `2010-2011` + `2011-2012` + `2012-2013` +
        `2013-2014` + `2014-2015` + `2015-2016`) AS total_crimes,
    p.Population,
    ROUND(SUM(`2005-2006` + `2006-2007` + `2007-2008` + `2008-2009` +
        `2009-2010` + `2010-2011` + `2011-2012` + `2012-2013` +
        `2013-2014` + `2014-2015` + `2015-2016`) / p.Population * 100000, 2)
        AS crimes_per_100k
FROM crime_stats c
JOIN province_population p ON c.Province = p.Province
GROUP BY c.Province, p.Population
ORDER BY crimes_per_100k DESC;


-- ============================================================
-- STAGE 5: ADVANCED SQL - WINDOW FUNCTIONS
-- ============================================================

-- Query 6: Station Rankings Within Each Province (RANK)
SELECT
    Province, Station,
    SUM(`2005-2006` + `2006-2007` + `2007-2008` + `2008-2009` +
        `2009-2010` + `2010-2011` + `2011-2012` + `2012-2013` +
        `2013-2014` + `2014-2015` + `2015-2016`) AS total_crimes,
    RANK() OVER (
        PARTITION BY Province
        ORDER BY SUM(`2005-2006` + `2006-2007` + `2007-2008` + `2008-2009` +
        `2009-2010` + `2010-2011` + `2011-2012` + `2012-2013` +
        `2013-2014` + `2014-2015` + `2015-2016`) DESC
    ) AS province_rank
FROM crime_stats
GROUP BY Province, Station
ORDER BY Province, province_rank;

-- Query 7: Year-on-Year Crime Change with Percentage (LAG)
SELECT
    year, total_crimes,
    LAG(total_crimes) OVER (ORDER BY year) AS previous_year,
    total_crimes - LAG(total_crimes) OVER (ORDER BY year) AS crime_change,
    ROUND(
        (total_crimes - LAG(total_crimes) OVER (ORDER BY year)) /
        LAG(total_crimes) OVER (ORDER BY year) * 100, 2
    ) AS pct_change
FROM (
    SELECT '2005-2006' AS year, SUM(`2005-2006`) AS total_crimes FROM crime_stats
    UNION ALL SELECT '2006-2007', SUM(`2006-2007`) FROM crime_stats
    UNION ALL SELECT '2007-2008', SUM(`2007-2008`) FROM crime_stats
    UNION ALL SELECT '2008-2009', SUM(`2008-2009`) FROM crime_stats
    UNION ALL SELECT '2009-2010', SUM(`2009-2010`) FROM crime_stats
    UNION ALL SELECT '2010-2011', SUM(`2010-2011`) FROM crime_stats
    UNION ALL SELECT '2011-2012', SUM(`2011-2012`) FROM crime_stats
    UNION ALL SELECT '2012-2013', SUM(`2012-2013`) FROM crime_stats
    UNION ALL SELECT '2013-2014', SUM(`2013-2014`) FROM crime_stats
    UNION ALL SELECT '2014-2015', SUM(`2014-2015`) FROM crime_stats
    UNION ALL SELECT '2015-2016', SUM(`2015-2016`) FROM crime_stats
) AS yearly_totals;

-- ============================================================
-- END OF ANALYSIS
-- ============================================================
