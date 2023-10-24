-- Transportation
-- Q5 Investigate whether there is any correlation between vehicle sales and 
-- specific months or seasons in different districts. Are there any months 
-- or seasons that consistently show higher or lower sales rate, and if yes, 
-- what could be the driving factors? (Consider Fuel-Type category only)
SELECT 
    month,
    CASE
        WHEN total_sale >= 1000000000 THEN CONCAT(ROUND(total_sale / 1000000000, 2), 'B')
        WHEN total_sale >= 1000000 THEN CONCAT(ROUND(total_sale / 1000000, 2), 'M')
        ELSE CONCAT(ROUND(total_sale / 1000, 2), 'K')
    END AS total_sales
FROM (
    SELECT 
        monthname(t.Date) AS month, 
        SUM(fuel_type_petrol) AS total_petrol_vehi_sales,
        SUM(fuel_type_diesel) AS total_disel_vehi_sales,
        SUM(fuel_type_electric) AS total_ele_vehi_sales,
        SUM(fuel_type_others) AS total_other_vehi_sales,
        SUM(fuel_type_petrol + fuel_type_diesel + fuel_type_electric + fuel_type_others) AS total_sale
    FROM fact_transport t
    GROUP BY month
) AS s
ORDER BY total_sales DESC;

-- Q6 How does the distribution of vehicles vary by vehicle class 
-- (MotorCycle, MotorCar, AutoRickshaw, Agriculture) across different 
-- districts? Are there any districts with a predominant preference for a 
-- specific vehicle class? Consider FY 2022 for analysis

SELECT district,
       sum(vehicleClass_MotorCycle) as total_motorcycle_usage,
       sum(vehicleClass_MotorCar) as total_motorcar_usage,
       sum(vehicleClass_AutoRickshaw) as total_auto_usage,
       sum(vehicleClass_Agriculture) as total_agri_usage,
       sum(vehicleClass_others) as total_others_usage,
       CASE
           WHEN sum(vehicleClass_MotorCycle) >= sum(vehicleClass_MotorCar) AND
                sum(vehicleClass_MotorCycle) >= sum(vehicleClass_AutoRickshaw) AND
                sum(vehicleClass_MotorCycle) >= sum(vehicleClass_Agriculture) AND
                sum(vehicleClass_MotorCycle) >= sum(vehicleClass_others) THEN 'Motorcycle'
           WHEN sum(vehicleClass_MotorCar) >= sum(vehicleClass_MotorCycle) AND
                sum(vehicleClass_MotorCar) >= sum(vehicleClass_AutoRickshaw) AND
                sum(vehicleClass_MotorCar) >= sum(vehicleClass_Agriculture) AND
                sum(vehicleClass_MotorCar) >= sum(vehicleClass_others) THEN 'Motorcar'
           WHEN sum(vehicleClass_AutoRickshaw) >= sum(vehicleClass_MotorCycle) AND
                sum(vehicleClass_AutoRickshaw) >= sum(vehicleClass_MotorCar) AND
                sum(vehicleClass_AutoRickshaw) >= sum(vehicleClass_Agriculture) AND
                sum(vehicleClass_AutoRickshaw) >= sum(vehicleClass_others) THEN 'Auto Rickshaw'
           WHEN sum(vehicleClass_Agriculture) >= sum(vehicleClass_MotorCycle) AND
                sum(vehicleClass_Agriculture) >= sum(vehicleClass_MotorCar) AND
                sum(vehicleClass_Agriculture) >= sum(vehicleClass_AutoRickshaw) AND
                sum(vehicleClass_Agriculture) >= sum(vehicleClass_others) THEN 'Agriculture'
           ELSE 'Others'
       END AS most_used_vehicle
FROM fact_transport t
JOIN dim_districts d
ON d.dist_code = t.dist_code
where year(Date) = 2022
GROUP BY district;

-- Q7 List down the top 3 and bottom 3 districts that have shown the highest 
-- and lowest vehicle sales growth during FY 2022 compared to FY 
-- 2021? (Consider and compare categories: Petrol, Diesel and Electric)

-- for petol
SELECT 
    district,
    total_sale_2022 - total_sale_2021 AS sales_growth,
    ROUND(((total_sale_2022 - total_sale_2021) / total_sale_2021) * 100, 2) AS sales_growth_percentage
FROM (
    SELECT 
        district,
        SUM(CASE WHEN YEAR(Date) = 2022 THEN  fuel_type_petrol ELSE 0 END) AS total_sale_2022,
        SUM(CASE WHEN YEAR(Date) = 2021 THEN  fuel_type_petrol ELSE 0 END) AS total_sale_2021
    FROM fact_transport i
    JOIN dim_districts d ON i.dist_code = d.dist_code
    GROUP BY district
) AS sales_by_district
ORDER BY sales_growth_percentage;

-- for disel

SELECT 
    district,
    total_sale_2022 - total_sale_2021 AS sales_growth,
    ROUND(((total_sale_2022 - total_sale_2021) / total_sale_2021) * 100, 2) AS sales_growth_percentage
FROM (
    SELECT 
        district,
        SUM(CASE WHEN YEAR(Date) = 2022 THEN  fuel_type_diesel ELSE 0 END) AS total_sale_2022,
        SUM(CASE WHEN YEAR(Date) = 2021 THEN  fuel_type_diesel ELSE 0 END) AS total_sale_2021
    FROM fact_transport i
    JOIN dim_districts d ON i.dist_code = d.dist_code
    GROUP BY district
) AS sales_by_district
ORDER BY sales_growth_percentage desc;

--  for electric

SELECT fact_transport
    district,
    total_sale_2022 - total_sale_2021 AS sales_growth,
    ROUND(((total_sale_2022 - total_sale_2021) / total_sale_2021) * 100, 2) AS sales_growth_percentage
FROM (
    SELECT 
        district,
        SUM(CASE WHEN YEAR(Date) = 2022 THEN  fuel_type_electric ELSE 0 END) AS total_sale_2022,
        SUM(CASE WHEN YEAR(Date) = 2021 THEN  fuel_type_electric ELSE 0 END) AS total_sale_2021
    FROM fact_transport i
    JOIN dim_districts d ON i.dist_code = d.dist_code
    GROUP BY district
) AS sales_by_district
ORDER BY sales_growth_percentage;




