-- Ts-Ipass
-- Q1
-- List down the top 5 sectors that have witnessed the most significant 
-- investments in FY 2022.


SELECT sector, round(SUM(investment),2) AS total_investment
FROM fact_ts_ipass
WHERE YEAR(Date) = 2022
GROUP BY sector
ORDER BY total_investment DESC
LIMIT 5;

-- Q2
-- List down the top 3 districts that have attracted the most significant 
-- sector investments during FY 2019 to 2022? What factors could have 
-- led to the substantial investments in these particular districts?

select district, round(sum(investment),2) as investments
from dim_districts d
join fact_ts_ipass i
on d.dist_code = i.dist_code
where year(date) between 2019 and 2022
group by  district
order by investments desc
limit 3;

-- Is there any relationship between district investments, vehicles
--  sales and stamps revenue within the same district between FY 2021
--  and 2022

select district, round(sum(investment),2) as investment
from dim_districts d
join fact_ts_ipass i
on d.dist_code = i.dist_code
where year(date) between 2021 and 2022
group by district
order by investment desc;

SELECT 
    district,
    CASE
        WHEN total_sale >= 1000000000 THEN CONCAT(ROUND(total_sale / 1000000000, 2), 'B')
        WHEN total_sale >= 1000000 THEN CONCAT(ROUND(total_sale / 1000000, 2), 'M')
        ELSE CONCAT(ROUND(total_sale / 1000, 2), 'K')
    END AS total_sales
FROM (
    SELECT 
        d.district,
        SUM(t.fuel_type_petrol) AS total_petrol_vehi_sales,
        SUM(t.fuel_type_diesel) AS total_disel_vehi_sales,
        SUM(t.fuel_type_electric) AS total_ele_vehi_sales,
        SUM(t.fuel_type_others) AS total_other_vehi_sales,
        SUM(t.fuel_type_petrol + t.fuel_type_diesel + t.fuel_type_electric + t.fuel_type_others) AS total_sale
    FROM fact_transport t
    JOIN dim_districts d ON d.dist_code = t.dist_code
    where year(Date) between 2021 and 2022
    GROUP BY d.district
) AS s
ORDER BY total_sale DESC;

select district, sum(estamps_challans_rev)as stamp_rev
from fact_stamps s
join dim_districts d
on d.dist_code = s.dist_code
where year(date) between 2021 and 2022
group by district;

with rev as(
SELECT district, 
       sum(estamps_challans_rev) as total_challan_rev
    FROM fact_stamps s
    join dim_districts d
    on d.dist_code = s.dist_code
    where year(date) between 2021 and 2022
    group by s.dist_code, district
    order by total_challan_rev desc)
  select district,  CASE
        WHEN total_challan_rev >= 1000000000 THEN CONCAT(ROUND(total_challan_rev / 1000000000, 2), ' B')
        WHEN total_challan_rev >= 1000000 THEN CONCAT(ROUND(total_challan_rev / 1000000, 2), ' M')
		WHEN total_challan_rev >= 10000 THEN CONCAT(ROUND(total_challan_rev / 10000, 2), ' k')
        ELSE total_challan_rev
        end as total_estamp_rev
from rev;

-- Is there any relationship between district investments, vehicles
--  sales and stamps revenue within the same district between FY 2021
--  and 2022
-- got headache by solving this
WITH Investment AS (
    SELECT 
        district,
        ROUND(SUM(investment), 2) AS total_investment
    FROM dim_districts d
    JOIN fact_ts_ipass i ON d.dist_code = i.dist_code
    WHERE YEAR(date) BETWEEN 2021 AND 2022
    GROUP BY district
),
VehicleSales AS (
    SELECT 
        district,
        CASE
            WHEN total_sale >= 1000000000 THEN CONCAT(ROUND(total_sale / 1000000000, 2), ' B')
            WHEN total_sale >= 1000000 THEN CONCAT(ROUND(total_sale / 1000000, 2), ' M')
            ELSE CONCAT(ROUND(total_sale / 1000, 2), ' K')
        END AS total_sales
    FROM (
        SELECT 
            d.district,
            SUM(t.fuel_type_petrol + t.fuel_type_diesel + t.fuel_type_electric + t.fuel_type_others) AS total_sale
        FROM fact_transport t
        JOIN dim_districts d ON d.dist_code = t.dist_code
        WHERE YEAR(Date) BETWEEN 2021 AND 2022
        GROUP BY d.district
    ) AS s
),
StampRevenue AS (
    SELECT 
        district,
        SUM(estamps_challans_rev) AS stamp_rev
    FROM fact_stamps s
    JOIN dim_districts d ON d.dist_code = s.dist_code
    WHERE YEAR(Date) BETWEEN 2021 AND 2022
    GROUP BY district
),
CombinedData AS (
    SELECT
        I.district,
        I.total_investment,
        V.total_sales AS total_vehicle_sales,
        S.stamp_rev AS total_stamp_revenue
    FROM Investment I
    JOIN VehicleSales V ON I.district = V.district
    JOIN StampRevenue S ON I.district = S.district
)
SELECT
    district,
    total_investment,
    total_vehicle_sales,
    CASE
        WHEN total_stamp_revenue >= 1000000000 THEN CONCAT(ROUND(total_stamp_revenue / 1000000000, 2), ' B')
        WHEN total_stamp_revenue >= 1000000 THEN CONCAT(ROUND(total_stamp_revenue / 1000000, 2), ' M')
        ELSE CONCAT(ROUND(total_stamp_revenue / 1000, 2), ' K')
    END AS total_stamp_revenue
FROM CombinedData;


-- Are there any particular sectors that have shown substantial 
--  investment in multiple districts between FY 2021 and 2022?
SELECT
    sector,
    ROUND(SUM(investment), 2) AS total_investment_in_CR,
    COUNT(DISTINCT district) AS districts_count
FROM
    fact_ts_ipass i
JOIN
    dim_districts d ON i.dist_code = d.dist_code
WHERE
    YEAR(Date) BETWEEN 2021 AND 2022
GROUP BY
    sector
ORDER BY
    districts_count DESC;
    
-- Can we identify any seasonal patterns or cyclicality in the 
--  investment trends for specific sectors? Do certain sectors 
--  experience higher investments during particular months?
select sector,year(Date) as year_in,round(sum(investment),2) as total_investment_CR
from fact_ts_ipass f
group by sector, year_in
having total_investment_CR > 100
order by year_in;


SELECT
    monthname(Date) AS month,
    AVG(ts.investment) AS average_investment,
    SUM(ts.investment) AS total_investment
FROM
    fact_TS_iPASS ts
WHERE
    ts.sector = 'Plastic and Rubber'
GROUP BY
    month
ORDER BY
    month;

select district, sector, sum(investment) as total_investment
from fact_ts_ipass t
join dim_districts d
on t.dist_code = d.dist_code
group by district, sector;

select year(Date) as year, sum(investment) as total_invest, sum(number_of_employees) as total_employees
from fact_ts_ipass
group by year;

select year(Date) as year, sum(fuel_type_petrol) as petrol, sum(fuel_type_diesel) as diesel,  sum(fuel_type_electric) as electric 
from fact_transport
group by year;


select count(district) as total_districts, sector, sum(investment) as total_investment
from fact_ts_ipass t
join dim_districts d
on t.dist_code = d.dist_code
group by  sector
order by total_districts desc limit 5;

