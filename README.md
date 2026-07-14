# NHS Primary Care Access & Operational Performance Analytics for May 2026

## Table of Contents
- [Project Background and Overview](#project-background-and-overview)
- [Executive Summary](#executive-summary)
- [Analytical Dashboard](#analytical-dashboard)
- [Business Problem](#business-problem)
- [Methodology](#methodology)
- [Skills](#skills)
- [Results and Business Recommendations](#results-and-business-recommendations)

You May Access Interractive Dashboard Here:
### https://app.powerbi.com/view?r=eyJrIjoiMmE0Mjk0YWUtMmNlMi00NTA2LTg2ZTgtMzBmNzkzMmZhMWJhIiwidCI6ImQ5NzRiNGRmLWVlYzItNDMzZS1hOTE4LTNmZTE4NDEyNzM1ZiIsImMiOjh9

### Datasets used:
English Indices of Deprivation (IMD): https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019
NHS Primary Care Appointments Data: https://digital.nhs.uk/data-and-information/publications/statistical/appointments-in-general-practice?__cf_chl_f_tk=ppq91JhbzoVMe8JYUZaNgEYIMSiORKOT.onSPtATh70-1784057919-1.0.1.1-fE5yMPfZo7fMFORSvrcoeEZDHwl8NyXoAr3UkmlyWjg
NHS England General Practice & ODS Code Mappings: https://digital.nhs.uk/services/organisation-data-service

---

## Project Background and Overview
This project aimed at an operational analytics pipeline to evaluate primary care appointment access across London Integrated Care Boards (ICBs).
Using millions of raw activity records from NHS public datasets, I built a relational data pipeline in SQL Server and cleaned, audited, transformed, and summarizeed health records for may 2026 into dimensional tables. These aggregated tables are opened in Power BI Desktop to construct an interactive executive dashboard. This dashboard tracks appointment accessibility, lead times, and delivery modes across London healthcare networks for the month of May 2026.

---

## Executive Summary
London primary care maintains the same day access for patients, achieving this by leaning heavily on remote consultation channels to maintain daily operational work.

### Key Operational Highlights
* **High Immediate Access:** 42.8% of primary care appointments in London are completed on the same day as booking. This proves solid triage capacity for urgent care
* **Heavy Remote Care Adoption:** 41.2% of appointments are delivered by telephone or digital channels. This shows a permanent operational move toward hybrid care models
* **Extended Backlog Risk:** Roughly 12.4% of appointments have booking lead times over 14 days, this shows specific pressure points in routine and non urgent scheduling

---

## Analytical Dashboard
<img width="1361" height="758" alt="image" src="https://github.com/user-attachments/assets/0d6732c7-a5dc-41f9-82ee-c83c9df70d50" />

### Dashboard Visual Features
* **Interactive Region Slicer (`Select ICB / Region`):** Filters report visuals to isolate specific ICB performance or review total London metrics dynamically
* **Top Level KPI Cards:** Display total appointment volume, same day access percentage, and remote care delivery rates at a glance
* **ICB Regional Access Matrix:** Shows detailed regional performance metrics with conditional formatting to highlight variations across ICBs
* **Care Delivery Mode Split:** Displays the distribution between in person appointments and remote consultations
* **Booking Lead Time Profile:** Tracks patient wait times across operational categories from same day to 28+ days
* **Total Volume Ranking:** Compares regional appointment volume across London Integrated Care Boards

---

## Business Problem
* **Triage Efficiency:** Is the primary care system meeting demand for urgent same day appointments, or are patients experiencing delays during initial contact?
* **Digital Care Transition:** How consistently are London regions using telephone and digital consultations to manage appointment volume?
* **Wait Time Backlogs:** Which booking lead time windows present the highest risk for appointment backlogs?
---

## Methodology

### Step 1: Getting the Data Ready (SQL Server)
* Looked through the raw practice and geographic files to make sure the row counts matched up and no key information was missing
* Trimmed extra spaces off GP practice codes using `TRIM` so that different datasets matched without dropping records
* Converted appointment counts safely using `TRY_CAST` to handle empty or invalid entries without breaking the queries

### Step 2: Organizing the Data View
* Created a simple SQL View named `vw_London_GP_Activity` to filter down the dataset to focus only on London healthcare regions
* Grouped the appointment data clearly by healthcare provider type, booking method, and wait times so it was easy to analyze.

### Step 3: Summarizing for Performance
* Instead of sending millions of individual rows to Power BI, I grouped the data into three smaller summary tables
* This pre-aggregation kept file sizes small and ensured the reporting visuals loaded instantly

### Step 4: Building Measures in Power BI
* **Same Day Access Rate:** 
  $$\text{Same Day Rate \%} = \frac{\text{SUM}(Same\_Day\_Appointments)}{\text{SUM}(Total\_Appointments)}$$
* **Remote Care Delivery Adoption:** 
  $$\text{Remote Care \%} = \frac{\text{SUM}(Remote\_Appointments)}{\text{SUM}(Total\_Appointments)}$$

---

## Skills

* **Database Management & SQL Server:** Data Auditing, `TRIM`, `TRY_CAST`, Relational Table Joins (`INNER`, `LEFT`), View Creation (`CREATE OR ALTER VIEW`), Summary Table Generation (`INTO Summary_*`).
* **ETL:** Data Pipelines, Query Optimization
* **Business Intelligence & Data Visualization:** Power BI Desktop, Interface Formatting
* **DAX & Analytics Modeling:** Explicit Measures, Ratio Normalization, Dimensional Aggregation
* **Healthcare Domain Knowledge:** NHS Primary Care Operations, Integrated Care Boards (ICBs), Primary Care Networks (PCNs), Access Triage, Wait Time Tracking

---

## Results and Business Recommendations

### Key Analytical Results
* **Strong Same Day Front Door Capacity:** 42.8% of primary care visits across London happen on the same day as booking, showing that urgent triage processes are operating effectively.
* **Established Hybrid Delivery Baseline:** Over 40% of appointments are completed remotely, showing us that primary care volume relies heavily on telephone and digital channels.
* **Consistent Regional Delivery:** Performance metrics remain uniform across all London Integrated Care Boards, showing that wait times are the same across London rather than localized
* **Current NHS Regional Alignment:** Data reflects the current NHS administrative structure where North West London and North Central London are combined as **NHS West and North London ICB**, taking into consideration all 32 London boroughs

### Actionable Business Recommendations
* **Standardize Remote Triage Protocols:** With over 40% of care delivered remotely, establish clear clinical triage guidelines across ICBs to ensure remote consultations are effective and limit unnecessary repeat visits
* **Targeted Backlog Management for 15+ Day Waiters:** Set up dedicated scheduling workflows to address 12% of patients waiting longer than two weeks for routine appointments
