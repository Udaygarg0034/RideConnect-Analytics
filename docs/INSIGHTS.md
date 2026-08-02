# Key Insights — RideConnect Analytics

Results below come from running `sql/03_business_analysis_queries.sql` against the
loaded dataset (3,000 users · 800 drivers · 45,000 rides across 10 cities).

## 1. Platform snapshot
- **₹38.36 lakh** in completed-ride revenue across **38,101 completed rides** (avg fare ≈ **₹100.7**).
- Overall cancellation rate sits at **10.2%** — a meaningful revenue leak worth investigating.

## 2. Cities
- **Hyderabad** leads on revenue (₹4.55L) despite Mumbai and Pune being close behind — Tier-1 cities dominate the top 5.
- **Chennai** has the highest cancellation rate (11.5%) among major cities, while **Delhi** has the lowest (9.6%) — worth a city-ops deep-dive.

## 3. Cancellations
- The six cancellation reasons are almost evenly split (~750-780 each): *User cancelled, Change of plans, Long wait time, Vehicle breakdown, Driver not reachable, Driver cancelled*. No single dominant cause — this points to several independent problems (driver reliability, vehicle maintenance, and wait-time/ETA accuracy) rather than one fixable root cause.

## 4. Vehicle mix
- **Mini** is the volume driver (14,146 rides, ~31% of completed rides) but **XL** and **Prime** carry the highest average fare (₹192 and ₹152) — a smaller, premium segment worth marketing harder.

## 5. Demand timing
- Demand is fairly flat through the day with a slight lean toward **late morning (10–11am)** and **late evening (9–11pm)** — commute + nightlife pattern.

## 6. Referral program
- Referred and organic users look nearly identical on average rides (8.0 each) and rating (4.27 vs 4.28) — in this dataset, the referral program isn't clearly producing higher-value customers, so its ROI should be evaluated on acquisition *cost*, not usage quality.

## 7. Driver tiers (Gold/Silver/Bronze via acceptance & cancellation rate)
- Only **~12% of drivers reach "Gold"** tier (acceptance ≥90%, cancellation ≤5%), but Gold drivers complete noticeably more rides on average (908 vs 702-740) — supply-side quality directly correlates with driver productivity.

## 8. Payments
- Success rates are fairly uniform across modes (~65-66%), meaning payment failures are likely a systemic/gateway issue rather than a mode-specific one — Wallet performs marginally best (66.3%).

## 9. Customer loyalty
- The bulk of the completed-ride base is repeat users: **1,592 users with 6-15 rides** and **1,021 "power users" with 15+ rides** — retention, not just acquisition, is where most of the ride volume already sits.

## 10. Service quality signals (feedback tags)
- Positive tags (*clean vehicle, professional, safe driving, polite behavior*) and negative tags (*rude behavior, late pickup, long route taken*) appear at similar frequency (~1,030-1,140 each) — a roughly even mix of praise and complaints, suggesting driver training/quality-control has room to move the needle.

---

*Numbers are generated directly from the dataset provided; re-run `sql/03_business_analysis_queries.sql`
after loading the data to reproduce or refresh these figures.*
