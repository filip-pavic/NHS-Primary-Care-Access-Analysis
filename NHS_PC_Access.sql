use NHS_Health_Inequalities

SELECT 'Practice_Level' AS table_name, COUNT(*) AS total_rows FROM dbo.Practice_Level
UNION ALL
SELECT 'GP'             , COUNT(*) FROM dbo.GP
UNION ALL
SELECT 'Mapping'        , COUNT(*) FROM dbo.Mapping
UNION ALL
SELECT 'Deprivation'    , COUNT(*) FROM dbo.Deprivation;
GO

-- Datasets successfully loaded

SELECT TOP 5 * FROM Practice_Level;
SELECT TOP 5 * FROM GP;
SELECT TOP 5 * FROM Mapping;
SELECT TOP 5 * FROM Deprivation;
GO

-- Data check

SELECT TOP 5 * FROM dbo.GP;
SELECT TOP 5 * FROM dbo.Mapping;
GO

-- Need to isolate **London area** from the data
-- Must join Practice_Level, GP and Deprivation

SELECT DISTINCT 
    comm_region_code, 
    comm_region_name, 
    icb_code, 
    icb_name
FROM dbo.GP
WHERE comm_region_name LIKE '%London%' 
   OR icb_name LIKE '%London%'
ORDER BY comm_region_name, icb_name;
GO

SELECT 
    COUNT(DISTINCT pl.gp_code) AS total_practices_in_activity,
    COUNT(DISTINCT g.PRACTICE_CODE) AS matched_practices_in_gp,
    COUNT(DISTINCT CASE WHEN g.PRACTICE_CODE IS NULL THEN pl.gp_code END) AS unmatched_practices
FROM dbo.Practice_Level pl
LEFT JOIN dbo.GP g 
    ON TRIM(pl.gp_code) = TRIM(g.PRACTICE_CODE);
GO

-- shows 11 unmatched practices, most likely newly opened or recently closed practices

SELECT TOP 1 * FROM GP;
SELECT TOP 1 * FROM Mapping;
GO

-- *****JOINING******
-- Practice_Level joins to GP on gp_code = PRACTICE_CODE
-- GP contains PRACTICE_POSTCODE
-- Deprivation contains LSOA CODE(2021) and deprivation deciles

SELECT TOP 1 * FROM dbo.Practice_Level;
GO

CREATE OR ALTER VIEW dbo.vw_London_GP_Activity AS
SELECT 
    -- 1 PRACTICE IDENTIFIERS
    TRIM(pl.GP_CODE) AS practice_code,
    g.PRACTICE_NAME AS practice_name,
    TRIM(g.PRACTICE_POSTCODE) AS practice_postcode,
    g.PCN_CODE AS pcn_code,
    g.PCN_NAME AS pcn_name,
    g.SUB_ICB_LOCATION_CODE AS sub_icb_code,
    g.SUB_ICB_LOCATION_NAME AS sub_icb_name,
    g.ICB_NAME AS icb_name,
    g.COMM_REGION_NAME AS comm_region_name,

    -- 2 APPTS CATEGORIZATIONS
    pl.HCP_TYPE AS hcp_type,
    pl.APPT_MODE AS appt_mode,
    pl.NATIONAL_CATEGORY AS national_category,
    pl.TIME_BETWEEN_BOOK_AND_APPT AS time_between_booking_and_appt,
    pl.APPT_STATUS AS appt_status,

    -- 3 ACTIVITY VOLUME
    TRY_CAST(pl.COUNT_OF_APPOINTMENTS AS INT) AS appointment_count

FROM dbo.Practice_Level pl
INNER JOIN dbo.GP g 
    ON TRIM(pl.GP_CODE) = TRIM(g.PRACTICE_CODE)
WHERE g.COMM_REGION_NAME = 'London';
GO

SELECT 
    COUNT(DISTINCT practice_code) AS total_london_practices,
    COUNT(DISTINCT icb_name) AS total_london_icbs,
    SUM(appointment_count) AS total_london_appointments
FROM dbo.vw_London_GP_Activity;
GO

/*

ANALYSIS

*/

SELECT icb_name, SUM(appointment_count) AS total_appts
FROM dbo.vw_London_GP_Activity
GROUP BY icb_name;

--GIVES ME TOTAL APPOINTMENTS BY ICB

SELECT icb_name, SUM(appointment_count) AS same_day_appts
FROM dbo.vw_London_GP_Activity
WHERE time_between_booking_and_appt = 'Same Day'
GROUP BY icb_name;

-- GIVES BACK SAME-DAY APPOINTMENTS BY ICB

-- Step 8a: Total appointments per ICB
SELECT 
    icb_name,
    COUNT(DISTINCT practice_code) AS total_practices,
    SUM(appointment_count) AS total_appointments
FROM dbo.vw_London_GP_Activity
GROUP BY icb_name
ORDER BY total_appointments DESC;
GO

-- Step 8b: Same-day appointments per ICB
SELECT 
    icb_name,
    SUM(appointment_count) AS same_day_appointments
FROM dbo.vw_London_GP_Activity
WHERE time_between_booking_and_appt = 'Same Day'
GROUP BY icb_name
ORDER BY same_day_appointments DESC;
GO

-- Step 8c: Appointments with wait times over 14 days per ICB
SELECT 
    icb_name,
    SUM(appointment_count) AS long_wait_appointments
FROM dbo.vw_London_GP_Activity
WHERE time_between_booking_and_appt IN ('15 to 21 Days', '22 to 28 Days', 'More than 28 Days')
GROUP BY icb_name
ORDER BY long_wait_appointments DESC;
GO

-- Who is delivering the care?
-- Step 9a: Total appointments by healthcare professional type across London
SELECT 
    hcp_type,
    SUM(appointment_count) AS total_appointments
FROM dbo.vw_London_GP_Activity
GROUP BY hcp_type
ORDER BY total_appointments DESC;
GO

-- Step 9b: Total appointments by ICB and staff type
SELECT 
    icb_name,
    hcp_type,
    SUM(appointment_count) AS total_appointments
FROM dbo.vw_London_GP_Activity
GROUP BY icb_name, hcp_type
ORDER BY icb_name, total_appointments DESC;
GO

-- Across every single ICB, the ratio barely moves.

-- APPOINTMENT MODE SPLIT 

-- Step 10: How are Londoners seeing their GP? (Appointment Mode)
SELECT 
    appt_mode,
    SUM(appointment_count) AS total_appointments
FROM dbo.vw_London_GP_Activity
GROUP BY appt_mode
ORDER BY total_appointments DESC;
GO

-- OVER 40% OF ALL PRIMARY CARE IN LONDON IS DELIVERED REMOTELY (Tel. or Digital).

SELECT TOP 5 * 
FROM dbo.Deprivation;
GO

SELECT TOP 5 
    GP_CODE, 
    GP_NAME, 
    SUB_ICB_LOCATION_CODE
FROM dbo.Mapping;
GO

-- 1. ICB Volume & Access Summary
SELECT 
    icb_name,
    COUNT(DISTINCT practice_code) AS total_practices,
    SUM(appointment_count) AS total_appointments
INTO dbo.Summary_ICB_Appointments
FROM dbo.vw_London_GP_Activity
GROUP BY icb_name;

-- 2. Wait Times Summary
SELECT 
    icb_name,
    time_between_booking_and_appt,
    SUM(appointment_count) AS total_appointments
INTO dbo.Summary_Wait_Times
FROM dbo.vw_London_GP_Activity
GROUP BY icb_name, time_between_booking_and_appt;

-- 3. Delivery Mode Summary (Face-to-Face vs Remote)
SELECT 
    icb_name,
    appt_mode,
    SUM(appointment_count) AS total_appointments
INTO dbo.Summary_Delivery_Mode
FROM dbo.vw_London_GP_Activity
GROUP BY icb_name, appt_mode;
GO

--- LONDON GP ACCESS IS FAST
-- 4 in 10 PATIENTS ARE TREATED REMOTELY
-- Access issues in London aren't isolated to one failing region—the operational model is running uniformly across the city.