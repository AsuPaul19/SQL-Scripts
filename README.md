# SQL-Scripts
Welcome to My SQL-Scripts repository! This project is a curated collection of SQL queries and scripts designed to assist with a wide range of database tasks, 
# including data analysis, reporting, optimization, and maintenance.  
# Repository Structure  
The scripts are organized by category or use case for easy navigation:


# SQL-Scripts Repository

A comprehensive, organized collection of SQL Server diagnostic and performance monitoring queries.  
These scripts help you evaluate SQL Server health, performance, memory usage, query costs, and configuration issues, based on improved and modernized versions of Glenn Berry’s scripts.

---

## Table of Contents

- Diagnostic Memory Scripts](#-diagnostic-memory-scripts)
- Query Performance Scripts](#-query-performance-scripts)
- Database & Table Insights](#️-database--table-insights)
- Security & Login Management](#-security--login-management)
- Availability Groups](#-availability-groups)
- Best Practices Included](#-best-practices-included)
- Notes](#-notes)
- Author and Credits](#-author-and-credits)

---

## Diagnostic Memory Scripts

| Script | Description |
|--------|-------------|
| `01_sys_memory_summary.sql` | Returns OS-level memory metrics including physical memory, page file, and system cache. |
| `02_sql_max_server_memory.sql` | Displays SQL Server's configured `max server memory (MB)` value. |
| `03_sql_process_memory_status.sql` | Shows SQL Server memory use, LPIM status, memory utilization percentage, and commit limits. |
| `04_page_life_expectancy.sql` | Lists PLE (Page Life Expectancy) for each NUMA node (memory pressure indicator). |
| `05_buffer_pool_usage_by_database.sql` | Displays how much buffer memory each database uses in MB and percentage. |
| `06_memory_grants_pending.sql` | Returns number of memory grants pending — a key metric for query memory pressure. |
| `07_memory_clerk_usage_summary.sql` | Top memory consumers by clerk type (e.g. ad hoc, buffer pool, etc.). |

---

##  Query Performance Scripts

| Script | Description |
|--------|-------------|
| `08_top_logical_reads_queries.sql` | Top 50 queries by total logical reads, with query text, execution stats, and plan. |
| `09_top_logical_reads_procs.sql` | Top 25 stored procedures by logical reads, calls per minute, and execution stats. |

---

##  Database & Table Insights

| Script | Description |
|--------|-------------|
| `10_table_sizes_with_compression.sql` | Lists table sizes, row counts, and data compression type. |
| `11_buffer_usage_by_object.sql` | Reports which tables and indexes are using the most memory in the buffer pool. |

---

##  Security & Login Management

| Script | Description |
|--------|-------------|
| `12_sysadmin_logins.sql` | Lists all logins that are members of the `sysadmin` fixed server role. |

---

##  Availability Groups

| Script | Description |
|--------|-------------|
| `13_ag_dashboard_metrics.sql` | Displays availability group replica states, sync health, queue sizes, and failover readiness. |

---

##  Best Practices Included

- Inline documentation and explanatory comments
- Safe use of `WITH (NOLOCK)` for read-only diagnostics (note potential side effects)
- `OPTION (RECOMPILE)` to prevent plan cache bloat
- Standardized output formatting and naming conventions
- Ranking and ratio-based insights for better interpretation
- Lightweight, non-blocking queries optimized for live monitoring

---

##  Notes

- These scripts are meant for **read-only diagnostics**. They do not modify any data or configuration.
- Designed for **SQL Server 2012 and newer**; compatible with most editions.
- Review and adapt scripts before scheduling them in production monitoring tools.

---

##  Author and Credits

- Author: Paul Asu  
- **Base Scripts**: Adapted from [Glenn Berry’s Diagnostic Queries](https://glennsqlperformance.com/)

---
