# Performance_Config_and_TempDB_Check.sql
  # Description
This script helps database administrators quickly assess key SQL Server configuration settings that impact query performance and TempDB efficiency. 
  It’s useful during performance tuning, environment baselining, or SQL Server health checks.

# What It Does
Check MAXDOP & Cost Threshold for Parallelism
Retrieves the current configuration values for:

1. max degree of parallelism (MAXDOP)

  * cost threshold for parallelism
  * These settings affect how SQL Server utilizes parallel processing and CPU resources.

2. Count Number of TempDB Files
Reports the number of data and log files configured for the TempDB system database.
Best practices suggest one data file per logical processor (up to 8) to minimize contention.

3. Display Detailed TempDB File Properties
Returns:
  * Logical and physical file names
  * File sizes
  * Growth configurations
Used to verify file uniformity and detect misconfigurations such as uneven growth settings.

# Usage
Run in SSMS or include as part of a regular server health check.

No changes are made to the system.

Ensure you have the appropriate permissions to query system views.
