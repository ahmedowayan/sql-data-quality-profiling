/* ============================================================
   DATA QUALITY & PROFILING ASSESSMENT — SQL Server (T-SQL)

-- Data Profiling--

-- Checking the data types in each table
SELECT
    table_name AS 'Table Name',
    column_name,
    data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name IN ('customer', 'employees', 'inventory', 'lease');


-- Row counts per table
SELECT 'customer' AS table_name, COUNT(*) AS row_count
FROM customer
UNION ALL
SELECT 'employees' AS table_name, COUNT(*) AS row_count
FROM employees
UNION ALL
SELECT 'inventory' AS table_name, COUNT(*) AS row_count
FROM inventory
UNION ALL
SELECT 'lease' AS table_name, COUNT(*) AS row_count
FROM lease;
-- Result: customer 2,000 | employees 5,871 | inventory 3,000 | lease 1,860


-- SECTION 1 — CUSTOMER TABLE 
SELECT * 
FROM customer;

-- Primary-key duplicate check
SELECT id, COUNT(*) AS duplicate_count
FROM Customer
GROUP BY id
HAVING COUNT(*) > 1;
-- Result: 0 rows — no duplicate customer IDs.

--Null Values / Completeness Checks
SELECT
SUM (CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS NULL_ID,
SUM (CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS NULL_NAME,
SUM (CASE WHEN establishment_type IS NULL THEN 1 ELSE 0 END) AS NULL_ESTABLISHMENT,
SUM (CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS NULL_COUNTRY,
SUM (CASE WHEN account_type IS NULL THEN 1 ELSE 0 END) AS NULL_ACCOUNT,
SUM (CASE WHEN start_date IS NULL THEN 1 ELSE 0 END) AS NULL_Date
FROM customer;


-- Customer name duplicate check
SELECT name, COUNT(*) AS Name_Duplication 
FROM customer
GROUP BY name
HAVING COUNT(*) >1
ORDER BY COUNT(*) DESC;
-- Result: 105 distinct names appear more than once (221 rows total)(Duplicate Names Only.

-- Real duplication (name and country)
SELECT name, country, COUNT (*) as Real_Duplication
FROM customer
GROUP BY name, country
HAVING COUNT (*) > 1
ORDER BY COUNT (*) DESC;
-- Result: 2 pairs (4 rows) — "Heathcote Inc" / Finland and "Sanford LLC" / Honduras


--Establishment type distribution
SELECT establishment_type, COUNT (*) AS Customer_Count
FROM customer
GROUP BY establishment_type
ORDER BY Customer_Count DESC;
-- MNC = 1037, SME = 963 -- 

-- Number of countries
SELECT COUNT (DISTINCT (country)) AS Number_Of_Countries
FROM customer;
-- We have 195 countries--

-- Number of customers per each country
SELECT country, COUNT (*) AS Number_of_countries_per_Customer
FROM customer
GROUP BY country
ORDER BY Number_of_countries_per_Customer DESC;
-- Tunisia is the country with the most number of countries with 20 customers

-- Company registeration per year -- 
SELECT YEAR (start_date) as Start_Year,
Count (start_date) as Company_Count
FROM customer
GROUP BY YEAR (start_date)
ORDER BY Company_Count DESC;
-- Result: 2015 was the peak year (98 new registrations)


--Null Values / Completeness Checks employees

SELECT * 
FROM Employees

-- Duplicate checks for empoyees id

SELECT id, COUNT(*) AS duplicate_count
FROM employees
GROUP BY id
HAVING COUNT(*) > 1;


-- Statsitics for the Employees table
SELECT
SUM (CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS NULL_ID,
SUM (CASE WHEN customer IS NULL THEN 1 ELSE 0 END) AS NULL_CUSTOMER,
SUM (CASE WHEN first_name IS NULL THEN 1 ELSE 0 END) AS NULL_First_NAME,
SUM (CASE WHEN last_name IS NULL THEN 1 ELSE 0 END) AS NULL_LAST_NAME,
SUM (CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS NULL_GENDER
FROM employees;

-- Showing row data for the NULL VALUES-- 

SELECT e.*
FROM employees e 
LEFT JOIN customer c
ON e.customer = c.id
WHERE c.id IS NULL;
-- Employee id 2669 and 4527 are not assigned to any customer (employer) -- 

SELECT gender, COUNT (gender) AS Gender_Count
FROM employees
GROUP BY gender
HAVING gender IS NOT NULL;


-- 23 employees with no assigned gender-- We should make it like a drop down menu to avoid such isses in the future
SELECT gender, COUNT (*) AS Gender_Count
FROM employees
GROUP BY gender
HAVING gender IS NULL;


-- Customer with the biggest emplyees number -- 

SELECT c.id, c.name, COUNT (e.customer) AS Employees_Count
FROM employees e
JOIN customer c
ON c.id= e.customer
GROUP BY c.id, c.name
ORDER BY Employees_Count DESC;

-- Listing the names of the employers with the most Employees_Count

SELECT TOP 10 c.id, c.name, COUNT (e.customer) AS Employees_Count
FROM customer c
JOIN employees e
ON c.id = e.customer
GROUP BY c.id, c.name
HAVING c.id IS NOT NULL
ORDER BY Employees_Count DESC;




--Null Values / Completeness Checks employees

SELECT * 
FROM inventory;

SELECT
SUM (CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS NULL_ID,
SUM (CASE WHEN unit_type IS NULL THEN 1 ELSE 0 END) AS NULL_UNIT_TYPE,
SUM (CASE WHEN unit_code IS NULL THEN 1 ELSE 0 END) AS NULL_UNIT_CODE,
SUM (CASE WHEN area IS NULL THEN 1 ELSE 0 END) AS NULL_AREA
FROM inventory;




-- Duplicate check for iventory id
SELECT id, COUNT(*) AS duplicate_count
FROM inventory
GROUP BY id
HAVING COUNT(*) > 1;

--Aea statistics  
SELECT
    MIN(area) AS min_area,
    MAX(area) AS max_area,
    AVG(area) AS avg_area
FROM inventory;

-- min_area is showing as negative -- 
SELECT *
FROM inventory
WHERE area < 0;

-- Office 328 is in negative area--

-- Customers with lease / no lease

SELECT * 
FROM lease;


-- Duolicate checks for lease id

SELECT id, COUNT(*) AS duplicate_count
FROM lease
GROUP BY id
HAVING COUNT(*) > 1;

SELECT
    MIN(amount) AS min_amount,
    MAX(amount) AS max_amount,
    AVG(amount) AS avg_amount
FROM lease;

-- Checking for negative values in lease table

SELECT *
FROM lease
WHERE amount <= 0 OR amount IS NULL;

SELECT unit_type, COUNT (Unit_type) AS unit_Type_Count
FROM lease
GROUP BY unit_type


-- Customers names who pays the most lease and unit type
SELECT c.name, l.amount, l.unit_type
FROM lease l
JOIN customer c
ON c.id = l.customer
ORDER BY l.amount DESC;

-- Type of leases and the number of leases
SELECT 
    c.id,
    c.name,
    COUNT(l.id) AS Lease_Count,
    CASE 
        WHEN COUNT(l.id) = 0 THEN 'No Lease'
        WHEN COUNT(l.id) = 1 THEN 'Single Lease'
        WHEN COUNT(l.id) > 1 THEN 'Multiple Leases'
    END AS Lease_Category
FROM customer c
LEFT JOIN lease l
    ON c.id = l.customer
GROUP BY c.id, c.name
ORDER BY Lease_Count DESC;

-- Mismatching Leases
SELECT
c.id,
c.name,
c.account_type,
CASE WHEN l.customer IS NULL THEN 'No Lease' Else 'Lease' END AS Actual_Status
FROM customer c 
LEFT JOIN (SELECT DISTINCT customer FROM lease) l
on c.id = l.customer 
WHERE c.account_type <> CASE WHEN l.customer IS NULL THEN 'No Lease' ELSE 'Lease' END;
-- Rows between 1118 and 1268 (151) are mismatching. Rows between 1850 and 2000 (151) are mismatching. Pattern. ETL issue 

-- Mismatching areas between lease and inventory tables despite having the exact same unit codes
SELECT l.id AS lease_id, l.unit_code, l.unit_area As Lease_Area, i.area AS Inventory_Area
FROM lease l
JOIN inventory i ON l.unit_code = i.unit_code
WHERE l.unit_area <> i.area; 
-- 6 areas are not matching with each other
