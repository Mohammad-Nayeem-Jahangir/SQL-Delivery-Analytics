# 🚚 Delivery Operations Analytics — SQL Business Case Study

> **Platform:** Google BigQuery &nbsp;|&nbsp; **Region:** us-central1 &nbsp;|&nbsp; **Project:** seraphic-port-489507-b1  
> **Queries:** 6 &nbsp;|&nbsp; **Domain:** Logistics & Last-Mile Delivery

---

## 📌 Project Overview

This project solves **6 real-world business questions** on a logistics delivery dataset using **Google BigQuery SQL**. The analysis covers delivery performance, SLA compliance, customer behavior patterns, delivery personnel efficiency, and operational anomaly detection from order logs.

Each query is independently structured, business-driven, and demonstrates a distinct set of advanced SQL techniques.

---

## 🗂️ Dataset Context

The dataset simulates a last-mile delivery operation and includes the following key tables:

| Table | Description |
|---|---|
| `orders` | Order-level records with status, delivery dates, and city information |
| `customers` | Customer profiles with registered address (format: `area, zone, city`) |
| `delivery_men` | Delivery personnel with joining date and working area |
| `order_logs` | Event-level log entries per order (city changes, status updates) |

---

## ❓ Business Questions & Approach

### Q1 — Delivery Success Rate and SLA Breach

**Business Goal:** Understand overall delivery health and identify how many orders violated SLA commitments.

- Calculated overall delivery success rate
- Computed daily average return ratio
- Flagged SLA breaches using conditional logic:
  - Same-city delivery → SLA = **24 hours**
  - Outside-city delivery → SLA = **48 hours**

**Key SQL Concepts:** `CASE WHEN`, `DATEDIFF`, `COUNT`, `GROUP BY`, conditional aggregation

---

### Q2 — Multiple Deliveries to the Same Customer

**Business Goal:** Identify loyal or high-frequency customers receiving more than one order in a short window.

- Found all customers who received **more than one order in the last 7 days**
- Returned total customer count with a supporting customer-level breakdown

**Key SQL Concepts:** `COUNT`, `GROUP BY`, `HAVING`, date filtering with `WHERE`

---

### Q3 — Registered City vs. Delivery City Mismatch

**Business Goal:** Detect customers receiving orders in cities different from where they are registered — useful for fraud detection and address validation.

- Parsed city from customer address string (format: `area, zone, city`)
- Joined with delivery records to compare registered city against delivery city
- Returned count of **distinct customers** with at least one mismatch

**Key SQL Concepts:** String parsing / `SPLIT`, `JOIN`, `DISTINCT`, subqueries

---

### Q4 — Top 3 Delivery Men per Delivery City

**Business Goal:** Recognize high-performing delivery personnel within each city for incentive planning.

- Ranked delivery men by total delivered order count within each `delivery_city`
- Returned top 3 per city using window-based ranking

**Key SQL Concepts:** `RANK()`, `PARTITION BY`, `ORDER BY`, CTEs

---

### Q5 — Delivery Men with Tenure > 30 Days and Return Ratio > 20%

**Business Goal:** Flag experienced delivery personnel with unusually high return rates for performance review.

- Calculated tenure relative to the **maximum `order_delivery_date`** in the dataset
- Filtered for tenure > 30 days AND return ratio > 20%

**Output columns:** `delivery_man_id`, `delivery_man_name`, `working_area`, `tenure_days`, `total_orders`, `returned_orders`, `return_ratio`

**Key SQL Concepts:** `DATEDIFF`, `MAX()`, ratio calculation, `HAVING`, aggregation

---

### Q6 — City Change Cases from Order Logs

**Business Goal:** Investigate orders where the delivery city was changed mid-process and assess their final outcomes.

- Identified all orders with a city change event in the `order_logs` table
- Reported reason for change, final delivery status, aging hours, SLA breach flag, and return outcome

**Output columns:** `order_id`, `city_change_reason`, `final_status`, `aging_hours`, `sla_breached`, + count of returned city-change orders

**Key SQL Concepts:** Log table analysis, `CASE WHEN`, SLA flagging, aggregation, `JOIN`

---

## 🧠 SQL Concepts Demonstrated

| Concept | Used In |
|---|---|
| Window Functions (`RANK`, `PARTITION BY`) | Q4 |
| CTEs (Common Table Expressions) | Q4, Q5 |
| Conditional Aggregation (`CASE WHEN`) | Q1, Q6 |
| Date Arithmetic (`DATEDIFF`, `MAX`) | Q1, Q5 |
| String Parsing (`SPLIT`, index extraction) | Q3 |
| Multi-table Joins | Q3, Q5, Q6 |
| SLA Logic Design | Q1, Q6 |
| Return Rate Analysis | Q5, Q6 |
| Subqueries & Filtering (`HAVING`, `WHERE`) | Q2, Q5 |

---

## 📁 Repository Structure

```
SQL-Delivery-Analytics/
│
├── README.md
├── Q1_delivery_success_rate_sla_breach.sql
├── Q2_multiple_deliveries_same_customer.sql
├── Q3_registered_vs_delivery_city_mismatch.sql
├── Q4_top3_delivery_men_per_city.sql
├── Q5_high_tenure_high_return_ratio.sql
└── Q6_city_change_cases_from_logs.sql
```

---

## 🛠️ Tools & Platform

- **Query Engine:** Google BigQuery (Standard SQL)
- **Environment:** Google Cloud Console
- **Region:** us-central1


