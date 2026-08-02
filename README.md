# Data Quality & Profiling Assessment — SQL Server
## Overview
Profiled a synthetic 4-table business dataset (customers,
employees, inventory, leases — ~12,700 rows) to assess data
quality across the DAMA dimensions. Data not included in repo.

## Framework
1. Schema & row counts
2. Primary key duplicate checks
3. Completeness (null analysis per column)
4. Referential integrity across tables
5. Range & validity checks
6. Cross-table consistency

## Key Findings
| # | Finding | Severity | Likely cause |
|---|---------|----------|--------------|
| 1 | 302 account-status mismatches in two contiguous ID ranges | High | ETL batch load failure |
| 2 | Negative area value (one unit) | Medium | Input validation gap |
| 3 | 2 orphaned employee records | Medium | Missing FK constraint |
| 4 | 6 area mismatches between lease and inventory | Medium | No single source of truth |
| 5 | 23 null gender values | Low | Free-text input field |

## Tools
SQL Server (SSMS), T-SQL
