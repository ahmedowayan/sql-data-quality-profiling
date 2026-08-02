<img width="1331" height="736" alt="image" src="https://github.com/user-attachments/assets/e452bf13-abba-4380-974f-2c4616648a27" /># Data Quality & Profiling Assessment — SQL Server

## Overview

Profiled a synthetic 4-table business dataset (customers, employees, inventory, leases — ~12,700 rows) to assess data quality across the DAMA dimensions. Data not included in repo.

In banking terms, these are the same checks that surface duplicate CIFs, incomplete KYC profiles, and orphaned account relationships — the data foundation of AML/KYC operations.

## Business Objective

The dataset supports customer management, leasing, and operational reporting. The objective was to answer three questions before the data could be trusted for reporting and decision-making:

1. Can each record be trusted individually? (completeness, validity, duplicates)
2. Do the tables agree with each other? (referential integrity, cross-table consistency)
3. Where issues exist, are they random errors or systematic failures — and what is the root cause?

The distinction in question 3 drove the most important finding: 302 mismatched records that looked like data entry noise were actually two failed ETL batch loads.

## Framework

1. Schema & row counts
2. Primary key duplicate checks
3. Completeness (null analysis per column)
4. Referential integrity across tables
5. Range & validity checks
6. Cross-table consistency

## Key Findings

All findings below are visualized in the Power BI dashboard (see Dashboard section).

| # | Finding | Severity | Likely cause |
|---|---------|----------|--------------|
| 1 | 302 account-status mismatches in two contiguous ID ranges | High | ETL batch load failure |
| 2 | Negative area value (one unit) | Medium | Input validation gap |
| 3 | 2 orphaned employee records | Medium | Missing FK constraint |
| 4 | 6 area mismatches between lease and inventory | Medium | No single source of truth |
| 5 | 23 null gender values | Low | Free-text input field |

## Recommendations

- Enforce a foreign key constraint on employees.customer to prevent orphaned records
- Add input validation preventing negative area and amount values at source
- Designate inventory as the master source for unit area; derive lease values from it
- Investigate the ETL pipeline for the two failed batch loads before correcting records
- Constrain gender to a fixed value list at input

## Dashboard

<img width="1331" height="736" alt="image" src="https://github.com/user-attachments/assets/c2067ad9-8ad3-4771-84ca-5f5e9ff765e0" />
<img width="1320" height="736" alt="image" src="https://github.com/user-attachments/assets/733c410a-8030-41ca-a002-0110218b1dc7" />

Power BI dashboard summarizing data quality KPIs and the findings above — issue counts by severity, mismatch distribution across ID ranges, and completeness metrics per table.

## Tools

SQL Server (SSMS), T-SQL, Power BI
