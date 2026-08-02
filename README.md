# 🚕 RideConnect Analytics — Multi-Modal Mobility Data Warehouse

A SQL data-warehousing + business-analytics capstone project built on a simulated
ride-hailing platform ("RideConnect") — modeled after multi-modal mobility apps
like Uber/Ola/Rapido. The project takes raw CSV data through **schema design →
relational database build → data loading → business-question SQL analysis →
insights**, in a single reproducible pipeline.

![ERD](docs/ERD_diagram.png)

## 📌 Problem Statement

RideConnect operates across 10 Indian cities with users, drivers, vehicles, and
rides all generating high-volume transactional data (rides, payments, ratings,
promotions). Leadership needs a **single relational data warehouse** to answer
recurring business questions: Which cities/vehicle types drive revenue? Why are
rides being cancelled? Are drivers being rewarded for good performance? Is the
referral program working? This project builds that warehouse from scratch and
answers those questions in SQL.

## 🗂️ Dataset

8 CSV files simulating a real mobility platform:

| Table | Rows | Description |
|---|---|---|
| `cities` | 10 | City master data (name, state, tier) |
| `users` | 3,000 | Riders — signup info, wallet, referrals, rating |
| `drivers` | 800 | Driver profiles — performance, acceptance/cancellation rate |
| `vehicles` | 800 | Vehicle master linked 1:1 to drivers |
| `rides` | 45,000 | **Fact table** — every ride, fare, status, timestamps |
| `payments` | ~40,000 | Transaction-level payment records per ride |
| `ratings_feedback` | ~29,700 | Post-ride ratings & feedback tags |
| `promotions` | ~6,800 | Coupon/campaign usage per ride |

## 🏗️ Data Model — Star Schema

`rides` is the central fact table; `users`, `drivers`, `vehicles`, and `cities`
are dimensions that feed into it, while `payments`, `ratings_feedback`, and
`promotions` are child tables of `rides`. Full ERD above; column-level detail
in [`sql/01_schema.sql`](sql/01_schema.sql).

```
cities ──> users ──> rides <── drivers ──> vehicles
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
    payments   ratings_feedback   promotions
```

`users.referred_by_user_id` is a self-referencing FK (referral chains), and
`drivers` ⇄ `vehicles` is a circular reference resolved by creating `vehicles`
after `drivers` and adding the `drivers.vehicle_id` FK with `ALTER TABLE`.

## 🛠️ Tech Stack

- **MySQL 8** (MySQL Workbench) — schema design, `LOAD DATA LOCAL INFILE`, DDL/DML/DQL
- **SQL concepts demonstrated**: multi-table JOINs, GROUP BY/HAVING, CASE-based
  segmentation, CTEs, window functions (`RANK`, running totals), correlated
  subqueries, string/date functions

## 🚀 How to Run This Project

1. **Clone the repo** and open MySQL Workbench.
2. Enable local file loading:
   - Server side: `SET GLOBAL local_infile = 1;`
   - Client side: *Database → Manage Connections → Advanced → Others:* `OPT_LOCAL_INFILE=1`
3. Run [`sql/01_schema.sql`](sql/01_schema.sql) to create the database and all 8 tables in the correct FK order.
4. Open [`sql/02_load_data.sql`](sql/02_load_data.sql), replace `REPLACE_WITH_YOUR_PATH` with your local path to the `/data` folder, and run it top to bottom (loads parents before children — cities → users → drivers → vehicles → rides → payments → ratings_feedback → promotions).
5. Run [`sql/03_business_analysis_queries.sql`](sql/03_business_analysis_queries.sql) to reproduce all 15 business-question queries.

## 📊 Key Business Questions Answered

1. What are the platform's overall KPIs (revenue, rides, cancellation rate)?
2. Which cities generate the most revenue, and where is cancellation highest?
3. What does the monthly revenue/ride trend look like?
4. Who are the top-10 revenue-generating drivers?
5. What are the leading causes of ride cancellation?
6. Which vehicle type is most profitable per ride?
7. What are the platform's peak demand hours?
8. Does the referral program actually produce more valuable users?
9. Which promo campaigns are used most, and at what discount cost?
10. How do payment success rates compare across modes?
11. How do drivers segment into performance tiers (Gold/Silver/Bronze)?
12. How does the user base segment by ride frequency (loyalty)?
13. How do cities rank on cumulative revenue contribution?
14. What are the most common pieces of ride feedback?
15. Which drivers are under-performing relative to the platform average?

Full write-up of findings: [`docs/INSIGHTS.md`](docs/INSIGHTS.md)

## 💡 Highlighted Insights

- Overall cancellation rate is **10.2%**, split almost evenly across 6 distinct
  causes — implying multiple independent problems rather than one root cause.
- **Mini** vehicles drive the most volume, but **XL/Prime** carry ~2x the
  average fare — a premium-segment growth lever.
- Only ~12% of drivers reach "Gold" performance tier, and they complete
  **~25-30% more rides** on average than Silver/Bronze drivers.
- Referred vs. organic users show **no meaningful difference** in ride
  frequency or rating — referral ROI should be judged on acquisition cost,
  not on user quality.

(Full details, including all supporting numbers, are in `docs/INSIGHTS.md`.)

## 📁 Repository Structure

```
RideConnect-Analytics/
├── README.md
├── data/                              # Raw CSVs (8 tables)
├── sql/
│   ├── 01_schema.sql                  # DDL — creates DB + 8 tables
│   ├── 02_load_data.sql               # LOAD DATA LOCAL INFILE for all tables
│   └── 03_business_analysis_queries.sql  # 15 business-question queries
└── docs/
    ├── ERD_diagram.png
    └── INSIGHTS.md                    # Written findings
```

## 🔮 Possible Extensions

- Connect this warehouse to Power BI / Tableau for a live dashboard layer.
- Add a driver-supply-vs-demand heatmap using `pickup_time` + `city_id`.
- Build a churn-prediction model on top of the `users`/`rides` tables in Python.

---
*Built as part of a Data Analytics capstone project.*
