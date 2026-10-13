/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================

-- Check for nulls or duplicates in primary key
-- Expectaion : No Result

SELECT 
*
FROM silver.crm_cust_info

SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL


-- Check for unwanted spaces
-- Expectation: No Results

SELECT
cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_lastname)

-- Data Standardization & Consistency

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info

-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

SELECT 
*
FROM silver.crm_prd_info

SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces
-- Expectation: No Results

SELECT
prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for Nulls or negative numbers

SELECT
prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standardization & Consistency

SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Invalid Date Orders
SELECT
*
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start

SELECT
prd_id,
prd_key,
prd_nm,
prd_start,
prd_end_dt,
LEAD(prd_start) OVER (PARTITION BY prd_key ORDER BY prd_start)-1 AS prd_end_dt_test
FROM silver.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509' , 'AC-HE-HL-U509-R')

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================
-- Check for unwanted spaces
-- Expectation: No Results

SELECT
sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Check sls_cust_id, sls_prd_key was not in silver layer tables

SELECT
*
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id from silver.crm_cust_info)

-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results
SELECT
NULLIF(sls_order_dt,0) AS sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt  = 0 OR sls_order_dt < 0 
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

SELECT
NULLIF(sls_ship_dt,0) AS sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt  = 0 OR sls_ship_dt < 0 
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101

SELECT
NULLIF(sls_due_dt,0) AS sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt  = 0 OR sls_due_dt < 0 
OR LEN(sls_due_dt) != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results

SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_due_dt OR sls_order_dt > sls_ship_dt

-- Check for Nulls or negative numbers sls_sales, sls_quantity, sls_price
-- Sales = Quantity * Price
-- Sales,quantity and prices should not be negative, zeros and nulls

SELECT DISTINCT
sls_sales
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales < 0 OR sls_quantity < 0 OR sls_price < 0
ORDER BY sls_sales, sls_quantity, sls_price

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================
-- Check for unwanted spaces
-- Expectation: No Results

SELECT
cid
FROM silver.erp_cust_az12
WHERE cid != TRIM(cid)

-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today

SELECT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data Standardization & Consistency

SELECT DISTINCT
gen
FROM silver.erp_cust_az12

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================
-- Check for unwanted spaces
-- Expectation: No Results

SELECT
cid
FROM silver.erp_loc_a101
WHERE cid != TRIM(cid)

-- Data Standardization & Consistency

SELECT DISTINCT
cntry
FROM silver.erp_loc_a101
ORDER BY cntry

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
*
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
OR subcat != TRIM(subcat) 
OR maintenance != TRIM(maintenance);

-- Data Standardization & Consistency

SELECT DISTINCT
cat
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT
subcat
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT
maintenance
FROM bronze.erp_px_cat_g1v2





