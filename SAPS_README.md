# South Africa Crime Statistics Analysis (2005-2016)

## Project Overview
This project performs an end-to-end data analysis of South African crime statistics from 2005 to 2016 using MySQL and Power BI. The analysis covers 17,020 records across 1,100 police stations, 9 provinces, and 25 crime categories — providing meaningful insights into crime distribution, trends, and provincial safety comparisons adjusted for population size.

---

## Objectives
- Load and manage large-scale crime data using MySQL
- Perform data exploration and quality checks using SQL
- Analyse crime patterns across provinces, stations and categories
- Calculate crime rates per capita using SQL JOINs
- Apply advanced SQL techniques including window functions
- Connect Power BI directly to MySQL for live dashboard reporting
- Communicate findings through an interactive dashboard with business insights

---

## Tools Used
- MySQL Server 8.0
- MySQL Workbench
- Power BI Desktop
- Microsoft Excel
- SQL (including Window Functions, JOINs, CTEs)

---

## Dataset Information

| File | Description |
|---|---|
| `crime_stats.csv` | 17,020 rows of crime data by station, province and category |
| `province_population.csv` | Population, area and density for all 9 provinces |

**Source:** Kaggle — South Africa Crime Statistics

### Columns in crime_stats:
| Column | Description |
|---|---|
| Province | One of 9 South African provinces |
| Station | Police station name (1,100 unique stations) |
| Category | Crime type (25 unique categories) |
| 2005-2006 to 2015-2016 | Crime count per financial year |

---

## Data Analysis Process

### 1. Data Import
Both datasets were imported into MySQL using the Table Data Import Wizard in MySQL Workbench, creating two relational tables: `crime_stats` and `province_population`.

### 2. Data Exploration
```sql
SELECT COUNT(*) AS total_rows FROM crime_stats;
SELECT COUNT(DISTINCT Province) AS total_provinces FROM crime_stats;
SELECT COUNT(DISTINCT Station) AS total_stations FROM crime_stats;
SELECT COUNT(DISTINCT Category) AS total_categories FROM crime_stats;
```

**Results:**
- Total rows: 17,020
- Provinces: 9
- Stations: 1,100
- Categories: 25

### 3. Data Quality Checks

| Check | Result |
|---|---|
| Missing Province values | 0 ✅ |
| Missing Station values | 0 ✅ |
| Missing Category values | 0 ✅ |
| Duplicate rows | None found ✅ |
| All-zero rows | None found ✅ |

> *"Data quality checks revealed no missing values, no duplicate records, and no redundant all-zero rows across all 17,020 records. The dataset required no cleaning, demonstrating that well-structured government datasets can sometimes be analysis-ready on import."*

### 4. Data Analysis

**Query 1 — Total Crimes by Province:**
```sql
SELECT Province,
       SUM(`2005-2006` + `2006-2007` + ... + `2015-2016`) AS total_crimes
FROM crime_stats
GROUP BY Province
ORDER BY total_crimes DESC;
```

**Query 2 — Most Common Crime Categories:**
```sql
SELECT Category,
       SUM(`2005-2006` + ... + `2015-2016`) AS total_crimes
FROM crime_stats
GROUP BY Category
ORDER BY total_crimes DESC;
```

**Query 3 — Top 10 Most Active Stations:**
```sql
SELECT Station, Province,
       SUM(`2005-2006` + ... + `2015-2016`) AS total_crimes
FROM crime_stats
GROUP BY Station, Province
ORDER BY total_crimes DESC
LIMIT 10;
```

**Query 4 — National Crime Trend:**
```sql
SELECT '2005-2006' AS year, SUM(`2005-2006`) AS total_crimes FROM crime_stats
UNION ALL SELECT '2006-2007', SUM(`2006-2007`) FROM crime_stats
-- ... continued for all 11 years
```

**Query 5 — Crime Rate Per Capita (JOIN):**
```sql
SELECT c.Province,
       SUM(...) AS total_crimes,
       p.Population,
       ROUND(SUM(...) / p.Population * 100000, 2) AS crimes_per_100k
FROM crime_stats c
JOIN province_population p ON c.Province = p.Province
GROUP BY c.Province, p.Population
ORDER BY crimes_per_100k DESC;
```

### 5. Advanced SQL — Window Functions

**RANK() — Station rankings within each province:**
```sql
RANK() OVER (
    PARTITION BY Province
    ORDER BY SUM(...) DESC
) AS province_rank
```

**LAG() — Year-on-year percentage change:**
```sql
total_crimes - LAG(total_crimes) OVER (ORDER BY year) AS crime_change,
ROUND((...) / LAG(total_crimes) OVER (ORDER BY year) * 100, 2) AS pct_change
```

---

## Key Findings

- **Gauteng** recorded the highest raw crime count with **6.6 million incidents** — nearly 30% of all national crime between 2005 and 2016
- **Western Cape** has the highest crime rate per capita at **80,212 per 100,000 people** — nearly 50% higher than Gauteng when adjusted for population
- **Limpopo** is the safest province per capita with only **20,711 crimes per 100,000 people**
- **Theft** is the most common crime nationally with over **4 million incidents** — property crimes collectively account for 37% of all crime
- **Mitchells Plain** (Western Cape) is the most active police station nationally with **278,476 total incidents**
- National crime **declined by 5.4%** overall from 2005 to 2016, with a brief uptick in 2008-2010 coinciding with the global financial crisis
- **Japanese directors** — wait, wrong project 😄 — **Murder and attempted murder** combined exceeded 350,000 cases over the period

---

## Dashboard Preview
> *Interactive Power BI dashboard built with a direct MySQL connection, featuring KPI cards, business insights and population-adjusted crime rates.*

![SAPS Dashboard](dashboard_screenshot.png)

---

## Skills Demonstrated
- SQL Querying & Aggregation
- Data Quality Checks
- Multi-table SQL JOINs
- Window Functions (RANK, LAG)
- Year-on-Year Analysis
- Per Capita Rate Calculations
- Power BI Dashboard Design
- Direct MySQL to Power BI Connection
- Business Insight Generation
- Data Storytelling

---

## Conclusion
This project demonstrates an advanced end-to-end data analytics workflow using MySQL and Power BI on a real South African government dataset. The analysis goes beyond simple aggregations — using JOINs for population-adjusted rates and window functions for rankings and trend analysis — producing insights that reflect how professional analysts approach crime and public safety data.

---

## Author
**Welcome Khayeni Molefe**
📁 GitHub: [github.com/Melcomex](https://github.com/Melcomex)
🌐 Portfolio: [portfolio-ashen-five-83.vercel.app](https://portfolio-ashen-five-83.vercel.app)
