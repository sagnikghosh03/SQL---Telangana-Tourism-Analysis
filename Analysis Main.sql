-- Provide Insights for Telangana Government Tourism Department--
/*
Task1:
Merge all individual CSV files in "domestic_visitors" and "foreign_visitors" folders using a data integration tool such as Pandas or PowerBI, and name the resulting files "domestic_visitors.csv" and "foreign_visitors.csv", respectively, containing all data from 2016 to 2019.

Task2:
Once the merged data is obtained, you can use it to answer the questions listed in the file 'research_questions_and_recommendations.pdf'. You can use any tool of your choice (Python, SQL, PowerBI, Tableau, Excel) to answer these questions.
 */

--Task1:--

/*Getting an overview of the already provided tables*/

/*domestic_visitor_tables*/

SELECT COLUMN_NAME,
       DATA_TYPE,
       IS_NULLABLE,
       COLUMN_DEFAULT,
       CHARACTER_MAXIMUM_LENGTH,
       NUMERIC_PRECISION,
       NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'domestic_visitors_2016';

/*foreigh_visitors_tables*/

SELECT COLUMN_NAME,
       DATA_TYPE,
       IS_NULLABLE,
       COLUMN_DEFAULT,
       CHARACTER_MAXIMUM_LENGTH,
       NUMERIC_PRECISION,
       NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'foreign_visitors_2016';

/*Creating Tables to combine all the years data*/

/*domestic_visitors_table*/

CREATE TABLE domestic_visitors
(
    district NVARCHAR(50),
    date DATE,
    month NVARCHAR(50),
    year SMALLINT,
    visitors INT NULL
);

/*foreigh_visitors_table*/

CREATE TABLE foreign_visitors
(
    district NVARCHAR(50),
    date DATE,
    month NVARCHAR(50),
    year SMALLINT,
    visitors INT NULL
);

/*Inserting all the years tables*/

/*domestic_visitor_tables*/

INSERT INTO domestic_visitors
(
    district,
    [date],
    [month],
    [year],
    visitors
)
SELECT district,
       [date],
       [month],
       [year],
       visitors
FROM domestic_visitors_2016
UNION ALL
SELECT district,
       [date],
       [month],
       [year],
       visitors
FROM domestic_visitors_2017
UNION ALL
SELECT district,
       [date],
       [month],
       [year],
       visitors
FROM domestic_visitors_2018
UNION ALL
SELECT district,
       [date],
       [month],
       [year],
       visitors
FROM domestic_visitors_2019;

/*foreigh_visitors_tables*/

INSERT INTO foreign_visitors
(
    district,
    [date],
    [month],
    [year],
    visitors
)
SELECT district,
       [date],
       [month],
       [year],
       visitors
FROM foreign_visitors_2016
UNION ALL
SELECT district,
       [date],
       [month],
       [year],
       visitors
FROM foreign_visitors_2017
UNION ALL
SELECT district,
       [date],
       [month],
       [year],
       visitors
FROM foreign_visitors_2018
UNION ALL
SELECT district,
       [date],
       [month],
       [year],
       visitors
FROM foreign_visitors_2019;

--Task1: Merging of files: Completed--

-----------------------------------------------------------------------------------------------

--Task2:--

--Exploratory Data Analysis--

/*Getting an overview of the two new tables with total data*/

/* take care of MULUGU and NARAYANPET*/

/*domestic_visitors*/

SELECT *
FROM domestic_visitors;

/*foreigh_visitors*/

SELECT *
FROM foreign_visitors;

/*Both the queries result in 1512 rows. There is no missing data. Hence no discrepancy.*/

--List of the top 10 districts that have the highest number of domestic visitors overall (2016-2019)--

SELECT TOP 10
    district,
    SUM(visitors) AS 'total_visitors'
FROM domestic_visitors
GROUP BY district
ORDER BY total_visitors DESC;

/*Insights*/

--List of the top 3 districts based on compounded annual growth rate (CAGR) of visitors between 2016 and 2019--



--What are the peak and low seasons for Hyderabad based on the data from 2016 to 2019 for Hyderabad district?--

/*domestic_visitors*/

SELECT [month],
       SUM(visitors) AS total_visitors
FROM domestic_visitors
WHERE district = 'HYDERABAD'
GROUP BY [month]
ORDER BY total_visitors DESC;

/*We can see that the highest peak is in the month of June (Summer) and December (Winter)*/

SELECT [month],
       SUM(visitors) AS total_visitors
FROM domestic_visitors
WHERE district = 'HYDERABAD'
GROUP BY [month]
ORDER BY total_visitors;

/*We can see that the low is in the months of February, March and September.*/

/*foreigh_visitors*/

SELECT [month],
       SUM(visitors) AS total_visitors
FROM foreign_visitors
WHERE district = 'HYDERABAD'
GROUP BY [month]
ORDER BY total_visitors DESC;

/*We can see that the highest peak is in the months of December, January and February (Winter)*/

SELECT [month],
       SUM(visitors) AS total_visitors
FROM foreign_visitors
WHERE district = 'HYDERABAD'
GROUP BY [month]
ORDER BY total_visitors;

/*We can see that the low is in the months of May, April and June (Summer).*/

--Find the top ranking districts for each year using window functions-- 

/*domestic_visitors*/

SELECT *
FROM
(
    SELECT year,
           district,
           SUM(visitors) AS total_visitors,
           RANK() OVER (PARTITION BY year ORDER BY SUM(visitors) DESC) AS rank
    FROM domestic_visitors
    GROUP BY district,
             [year]
) ranking
WHERE ranking.rank <= 5;

/*foreign_visitors*/

SELECT *
FROM
(
    SELECT year,
           district,
           SUM(visitors) AS total_visitors,
           RANK() OVER (PARTITION BY year ORDER BY SUM(visitors) DESC) AS rank
    FROM foreign_visitors
    GROUP BY district,
             [year]
) ranking
WHERE ranking.rank <= 5;

--Find the top ranking months for each year using window functions-- 

/*domestic_visitors*/

SELECT *
FROM
(
    SELECT year,
           [month],
           SUM(visitors) AS total_visitors,
           RANK() OVER (PARTITION BY year ORDER BY SUM(visitors) DESC) AS rank
    FROM domestic_visitors
    GROUP BY [month],
             [year]
) ranking
WHERE ranking.rank <= 3;

/*foreign_visitors*/

SELECT *
FROM
(
    SELECT year,
           [month],
           SUM(visitors) AS total_visitors,
           RANK() OVER (PARTITION BY year ORDER BY SUM(visitors) DESC) AS rank
    FROM foreign_visitors
    GROUP BY [month],
             [year]
) ranking
WHERE ranking.rank <= 3;

--What are the top & bottom 3 districts with high domestic to foreign tourist ratio?--

/*Top 3*/

/*Method 1: Using Subqueries*/

/* find a way to avoid divide by zero errors*/

SELECT TOP 3
    district,
    domestic_tourist,
    foreign_tourist,
    domestic_tourist / foreign_tourist AS ratio
FROM
(
    SELECT district AS domestic_district,
           SUM(visitors) AS domestic_tourist
    FROM domestic_visitors
    GROUP BY district
    HAVING SUM(visitors) <> 0
) AS domestic_tourists
    JOIN
    (
        SELECT district,
               SUM(visitors) AS foreign_tourist
        FROM foreign_visitors
        GROUP BY district
        HAVING SUM(visitors) <> 0
    ) AS foreign_tourists
        ON domestic_tourists.domestic_district = foreign_tourists.district
ORDER BY ratio;


/*Method 2: Using CTE's or Subquery factoring*/

WITH CTE_Domestic_Tourists
AS (SELECT district,
           SUM(visitors) AS domestic_tourist
    FROM domestic_visitors
    GROUP BY district
    HAVING SUM(visitors) <> 0
   ),
     CTE_Foreign_Tourists
AS (SELECT district,
           SUM(visitors) AS foreign_tourist
    FROM foreign_visitors
    GROUP BY district
    HAVING SUM(visitors) <> 0
   )
SELECT TOP 3
    CTE_Domestic_Tourists.district,
    domestic_tourist,
    foreign_tourist,
    domestic_tourist / foreign_tourist AS ratio
FROM CTE_Domestic_Tourists
    JOIN CTE_Foreign_Tourists
        ON CTE_Domestic_Tourists.district = CTE_Foreign_Tourists.district
ORDER BY ratio;

/*
Method 2 is better in terms of optimization and speed because CTEs are pre-compiled and stored in memory, which can improve the performance of queries that use them. Subqueries, on the other hand, are not pre-compiled and are evaluated each time they are executed, which can make them slower.
Overall, CTEs are a better choice than subqueries for most queries. They are more efficient, more readable, and more maintainable.
*/

/*Insights*/

/*Bottom 3*/

WITH CTE_Domestic_Tourists
AS (SELECT district,
           SUM(visitors) AS domestic_tourist
    FROM domestic_visitors
    GROUP BY district
    HAVING SUM(visitors) <> 0
   ),
     CTE_Foreign_Tourists
AS (SELECT district,
           SUM(visitors) AS foreign_tourist
    FROM foreign_visitors
    GROUP BY district
    HAVING SUM(visitors) <> 0
   )
SELECT TOP 3
    CTE_Domestic_Tourists.district,
    domestic_tourist,
    foreign_tourist,
    domestic_tourist / foreign_tourist AS ratio
FROM CTE_Domestic_Tourists
    JOIN CTE_Foreign_Tourists
        ON CTE_Domestic_Tourists.district = CTE_Foreign_Tourists.district
ORDER BY ratio DESC;

/*Insights*/

--What are the top 5 and bottom 5 districts based on 'Population to Tourisst Footfall Ratio' in 2019?--

/*Getting an overview of the demographics table*/

SELECT *
FROM demographics;

/*Need to add a new column for population in 2019*/

ALTER TABLE demographics ADD population_2019 INT;

/*Estimating and inserting data into the newly added column*/
/*Esmitating the population in 2019 using the census of 2011 and the estimated values of 2023*/

UPDATE demographics
SET population_2019 = As_per_2011_census
                      + ((Estimated_Population_in_2023 - As_per_2011_census) / (2023 - 2011) * (2019 - 2011));

/*In this query, we use the formula for linear interpolation: EstimatedPopulation2019 = Population2011 + ((Population2023 - Population2011) / (2023-2011) * (2019 - 2011)). This formula calculates the estimated population for the year 2019 based on the population data we have for the years 2011 and 2023.*/

/*Top 5 districts based on 'Population to Tourisst Footfall Ratio'*/

/* find a way to increase the ratio decimals to 2*/

WITH CTE_Domestic_Tourists
AS (SELECT district,
           SUM(visitors) AS domestic_tourist
    FROM domestic_visitors
    WHERE domestic_visitors.[year] = 2019
    GROUP BY district
   ),
     CTE_Foreign_Tourists
AS (SELECT district,
           SUM(visitors) AS foreign_tourist
    FROM foreign_visitors
    WHERE foreign_visitors.[year] = 2019
    GROUP BY district
   )
SELECT TOP 5
    CTE_Domestic_Tourists.district,
    demographics.population_2019,
    domestic_tourist,
    foreign_tourist,
    domestic_tourist + foreign_tourist AS total_visitors,
    (domestic_tourist + foreign_tourist) / demographics.population_2019 AS ratio
FROM CTE_Domestic_Tourists
    JOIN CTE_Foreign_Tourists
        ON CTE_Domestic_Tourists.district = CTE_Foreign_Tourists.district
    JOIN demographics
        ON demographics.Districts = CTE_Foreign_Tourists.district
ORDER BY ratio DESC;

/*Bottom 5 districts based on 'Population to Tourisst Footfall Ratio'*/

WITH CTE_Domestic_Tourists
AS (SELECT district,
           SUM(visitors) AS domestic_tourist
    FROM domestic_visitors
    WHERE domestic_visitors.[year] = 2019
    GROUP BY district
   ),
     CTE_Foreign_Tourists
AS (SELECT district,
           SUM(visitors) AS foreign_tourist
    FROM foreign_visitors
    WHERE foreign_visitors.[year] = 2019
    GROUP BY district
   )
SELECT TOP 5
    CTE_Domestic_Tourists.district,
    demographics.population_2019,
    domestic_tourist,
    foreign_tourist,
    domestic_tourist + foreign_tourist AS total_visitors,
    (domestic_tourist + foreign_tourist) / demographics.population_2019 AS ratio
FROM CTE_Domestic_Tourists
    JOIN CTE_Foreign_Tourists
        ON CTE_Domestic_Tourists.district = CTE_Foreign_Tourists.district
    JOIN demographics
        ON demographics.Districts = CTE_Foreign_Tourists.district
ORDER BY ratio;

/*To find ratios that are not null*/

WITH CTE_Domestic_Tourists
AS (SELECT district,
           SUM(visitors) AS domestic_tourist
    FROM domestic_visitors
    WHERE domestic_visitors.[year] = 2019
    GROUP BY district
   ),
     CTE_Foreign_Tourists
AS (SELECT district,
           SUM(visitors) AS foreign_tourist
    FROM foreign_visitors
    WHERE foreign_visitors.[year] = 2019
    GROUP BY district
   )
SELECT TOP 5
    CTE_Domestic_Tourists.district,
    demographics.population_2019,
    domestic_tourist,
    foreign_tourist,
    domestic_tourist + foreign_tourist AS total_visitors,
    (domestic_tourist + foreign_tourist) / demographics.population_2019 AS ratio
FROM CTE_Domestic_Tourists
    JOIN CTE_Foreign_Tourists
        ON CTE_Domestic_Tourists.district = CTE_Foreign_Tourists.district
    JOIN demographics
        ON demographics.Districts = CTE_Foreign_Tourists.district
WHERE (domestic_tourist + foreign_tourist) / demographics.population_2019 IS NOT NULL
ORDER BY ratio;

--What will be the projected number of domestic and foreign tourists in Hyderabad in 2025? --

/*Projected domestic tourists in 2025 */







WITH CombinedVisitors
AS (SELECT 'domestic' AS visitor_type,
           district,
           year,
           visitors
    FROM domestic_visitors
    WHERE district = 'Hyderabad'
    UNION ALL
    SELECT 'foreign' AS visitor_type,
           district,
           year,
           visitors
    FROM foreign_visitors
    WHERE district = 'Hyderabad'
   ),
     ProjectedVisitors
AS (SELECT district,
           '2025' AS year,
           SUM(   CASE
                      WHEN visitor_type = 'domestic' THEN
                          visitors
                      ELSE
                          0
                  END
              ) AS projected_domestic_visitors,
           SUM(   CASE
                      WHEN visitor_type = 'foreign' THEN
                          visitors
                      ELSE
                          0
                  END
              ) AS projected_foreign_visitors
    FROM CombinedVisitors
    GROUP BY district
   )
SELECT district,
       projected_domestic_visitors,
       projected_foreign_visitors
FROM ProjectedVisitors;




-- Calculate growth rates for domestic visitors
SELECT AVG((D1.visitors - D2.visitors) / D2.visitors) AS avg_domestic_growth_rate
FROM domestic_visitors D1
    JOIN domestic_visitors D2
        ON D1.district = D2.district
           AND D1.year = D2.year + 1;

-- Calculate growth rates for foreign visitors
SELECT AVG((F1.visitors - F2.visitors) / F2.visitors) AS avg_foreign_growth_rate
FROM foreign_visitors F1
    JOIN foreign_visitors F2
        ON F1.district = F2.district
           AND F1.year = F2.year + 1;

-- Project visitors for 2025 based on growth rates
SELECT 'Hyderabad' AS district,
       '2025' AS year,
       DV.visitors * (1 + avg_domestic_growth_rate) AS projected_domestic_visitors,
       FV.visitors * (1 + avg_foreign_growth_rate) AS projected_foreign_visitors
FROM domestic_visitors DV
    JOIN foreign_visitors FV
        ON DV.district = FV.district
           AND DV.year = FV.year
WHERE DV.district = 'Hyderabad'
      AND DV.year = 2019;
