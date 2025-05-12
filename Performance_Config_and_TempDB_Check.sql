/**********************************************************************
-- Script: Performance_Config_and_TempDB_Check.sql
-- Purpose: 
--   1. Review SQL Server instance settings related to parallelism.
--   2. Check TempDB file configuration for best practices.
-- Author: Paul Asu
-- Date: 2025-05-12
**********************************************************************/

-- ============================================
-- Section 1: Check MAXDOP and Cost Threshold Settings
-- ============================================
-- Retrieves current configuration for:
--   - max degree of parallelism (MAXDOP)
--   - cost threshold for parallelism
-- These settings impact query parallelism and CPU utilization.

SELECT 
    name AS [Configuration Name],         -- Name of the configuration option
    value AS [Configured Value],          -- Value set by user/admin
    value_in_use AS [Value In Use],       -- Currently active value (after RECONFIGURE or restart)
    description                           -- Description of the option
FROM sys.configurations
WHERE name IN (
    'max degree of parallelism', 
    'cost threshold for parallelism'      -- Filters only relevant settings
);

-- ============================================
-- Section 2: Count the Number of TempDB Files
-- ============================================
-- Best practice recommends 1 data file per logical processor (up to 8) 
-- to reduce TempDB contention (e.g., PFS/GAM/SGAM latch waits).

USE tempdb;  -- Switch context to the TempDB system database
GO

SELECT 
    type_desc AS [File Type],             -- Data or Log file
    COUNT(*) AS [Number of Files]         -- Number of each type (usually interested in Data files)
FROM sys.master_files
WHERE database_id = DB_ID('tempdb')       -- Ensures we're only looking at TempDB files
GROUP BY type_desc;                       -- Grouped by Data/Log type

-- ============================================
-- Section 3: Detailed TempDB File Info
-- ============================================
-- Shows individual TempDB file properties to check consistency in:
--   - File sizes
--   - Growth settings
--   - Physical locations

SELECT 
    name AS [Logical File Name],          -- SQL Server internal file name
    physical_name AS [Physical File Path],-- Full file system path to the file
    size/128 AS [Size in MB],             -- File size in MB (SQL stores size in 8KB pages)
    growth/128 AS [Growth in MB],         -- Growth increment (MB or % if percent flag is set)
    is_percent_growth AS [Is Growth in Percent] -- 1 = percent growth; 0 = fixed MB growth
FROM sys.master_files
WHERE database_id = DB_ID('tempdb');      -- Only includes TempDB files
