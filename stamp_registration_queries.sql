-- Stamp Registration
-- Q1.
-- How does the revenue generated from document registration vary 
-- across districts in Telangana? 
SELECT
    s.dist_code,
    d.district,
    CASE
        WHEN total_revenue >= 1000000000 THEN CONCAT(ROUND(total_revenue / 1000000000, 2), 'B')
        WHEN total_revenue >= 1000000 THEN CONCAT(ROUND(total_revenue / 1000000, 2), 'M')
        ELSE total_revenue
    END AS formatted_total_revenue
FROM
    (SELECT
        s.dist_code,
        SUM(documents_registered_rev) AS total_revenue
    FROM
        fact_stamps s
    GROUP BY
        s.dist_code) AS s
JOIN
    dim_districts d ON d.dist_code = s.dist_code
ORDER BY
    total_revenue desc;
--   
-- List down the top 5 districts that showed 
-- the highest document registration revenue growth between FY 2019 
-- and 2022

with topdistricts as(
		select dist_code,sum(documents_registered_rev) as total_rev 
        from fact_stamps
		where year(Date) between 2019 and 2022
		group by dist_code
		order by total_rev desc limit 5)
select district, total_rev
from dim_districts d
join topdistricts t
on d.dist_code = t.dist_code
order by total_rev desc;



-- Q2 How does the revenue generated from document registration compare 
-- to the revenue generated from e-stamp challans across districts? 
with rev as(
SELECT district, 
	   SUM(documents_registered_rev) AS total_revenue_doc,
       sum(estamps_challans_rev) as total_challan_rev
    FROM fact_stamps s
    join dim_districts d
    on d.dist_code = s.dist_code
    group by s.dist_code, district)
    
select district,
CASE
        WHEN total_revenue_doc >= 1000000000 THEN CONCAT(ROUND(total_revenue_doc / 1000000000, 2), 'B')
        WHEN total_revenue_doc >= 1000000 THEN CONCAT(ROUND(total_revenue_doc / 1000000, 2), 'M')
		WHEN total_revenue_doc >= 10000 THEN CONCAT(ROUND(total_revenue_doc / 10000, 2), 'k')
        ELSE total_revenue_doc
        end as total_rev_doc,
CASE
        WHEN total_challan_rev >= 1000000000 THEN CONCAT(ROUND(total_challan_rev / 1000000000, 2), 'B')
        WHEN total_challan_rev >= 1000000 THEN CONCAT(ROUND(total_challan_rev / 1000000, 2), 'M')
		WHEN total_challan_rev >= 10000 THEN CONCAT(ROUND(total_challan_rev / 10000, 2), 'k')
        ELSE total_challan_rev
        end as total_estamp_rev
from rev
order by total_estamp_rev desc;

-- List 
-- down the top 5 districts where e-stamps revenue contributes 
-- significantly more to the revenue than the documents in FY 2022?
with rev as (
SELECT district,      
       SUM(estamps_challans_rev) AS total_challan_rev,
	SUM(documents_registered_rev) AS total_rev 
	   FROM fact_stamps s
	   join dim_districts d
	   on d.dist_code = s.dist_code
	   where year(Date) = 2022
    group by district
    having total_challan_rev > total_rev
    limit 5)
select district,
CASE
        WHEN total_challan_rev >= 1000000000 THEN CONCAT(ROUND(total_challan_rev / 1000000000, 2), 'B')
        WHEN total_challan_rev >= 1000000 THEN CONCAT(ROUND(total_challan_rev / 1000000, 2), 'M')
		WHEN total_challan_rev >= 10000 THEN CONCAT(ROUND(total_challan_rev / 10000, 2), 'k')
        ELSE total_challan_rev
        end as total_estamp_rev
from rev
order by total_estamp_rev desc;


SELECT d.district, 
       SUM(s.estamps_challans_rev) AS total_challan_rev,
       SUM(s.documents_registered_rev) AS total_rev
FROM fact_stamps s
JOIN dim_districts d
ON d.dist_code = s.dist_code
WHERE YEAR(s.Date) = 2022
GROUP BY d.district
ORDER BY (total_challan_rev - total_rev) DESC
LIMIT 5;

-- Q3 Is there any alteration of e-Stamp challan count and document 
-- registration count pattern since the implementation of e-Stamp 
-- challan? If so, what suggestions would you propose to the 
-- government?

SELECT fiscal_year,
    CASE 
        WHEN total_registration_count >= 1000000 THEN CONCAT(ROUND(total_registration_count / 1000000, 2), 'M')
        WHEN total_registration_count >= 1000 THEN CONCAT(ROUND(total_registration_count / 1000, 2), 'K')
        ELSE total_registration_count
    END AS formatted_total_registration_count,
    CASE 
        WHEN total_estamps_count >= 1000000 THEN CONCAT(ROUND(total_estamps_count / 1000000, 2), 'M')
        WHEN total_estamps_count >= 1000 THEN CONCAT(ROUND(total_estamps_count / 1000, 2), 'K')
        ELSE total_estamps_count
    END AS formatted_total_estamps_count
FROM (
    SELECT YEAR(Date) AS fiscal_year,
        SUM(documents_registered_cnt) AS total_registration_count,
        SUM(estamps_challans_cnt) AS total_estamps_count
    FROM fact_stamps
    GROUP BY YEAR(date)
) AS subquery
GROUP BY fiscal_year
ORDER BY fiscal_year;


-- Q4 Categorize districts into three segments based on their stamp 
-- registration revenue generation during the fiscal year 2021 to 2022
SELECT
    district,
    CASE
        WHEN total_estamps_rev >= 1000000000 THEN CONCAT(ROUND(total_estamps_rev / 1000000000, 2), 'B')
        WHEN total_estamps_rev >= 1000000 THEN CONCAT(ROUND(total_estamps_rev / 1000000, 2), 'M')
        ELSE CONCAT(total_estamps_rev, '')
    END AS estamps_rev,
    CASE
        WHEN total_estamps_rev >= 1000000000 THEN 'High revenue'
        WHEN total_estamps_rev >= 500000000 THEN 'Medium revenue'
        ELSE 'Low Revenue'
    END AS revenue_category
FROM (
    SELECT
        d.district,
        SUM(estamps_challans_rev) AS total_estamps_rev
    FROM fact_stamps s
    JOIN dim_districts d ON d.dist_code = s.dist_code
    WHERE YEAR(Date) BETWEEN 2021 AND 2022
    GROUP BY d.district
) AS subquery
ORDER BY total_estamps_rev DESC;



