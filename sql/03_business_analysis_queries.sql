-- =====================================================================
-- RideConnect Analytics — Multi-Modal Mobility Data Warehouse
-- 03_business_analysis_queries.sql
--
-- 15 business questions solved with SQL: multi-table JOINs, GROUP BY /
-- HAVING, CASE-based segmentation, CTEs, window functions, and subqueries.
-- Run after 01_schema.sql and 02_load_data.sql.
-- =====================================================================

USE mobility_analytics;

-- ---------------------------------------------------------------------
-- Q1. Overall platform KPIs (subquery-based single-row summary)
-- ---------------------------------------------------------------------
SELECT
  (SELECT COUNT(*) FROM users)  AS total_users,
  (SELECT COUNT(*) FROM drivers) AS total_drivers,
  (SELECT COUNT(*) FROM rides)   AS total_rides,
  (SELECT ROUND(SUM(total_fare),2) FROM rides WHERE ride_status = 'completed') AS total_revenue,
  (SELECT ROUND(AVG(total_fare),2) FROM rides WHERE ride_status = 'completed') AS avg_fare,
  (SELECT ROUND(100.0 * SUM(ride_status='cancelled') / COUNT(*), 2) FROM rides) AS cancellation_pct;

-- ---------------------------------------------------------------------
-- Q2. City-wise revenue, ride volume and cancellation rate
-- ---------------------------------------------------------------------
SELECT
  c.city_name,
  c.tier,
  COUNT(r.ride_id) AS total_rides,
  ROUND(SUM(CASE WHEN r.ride_status = 'completed' THEN r.total_fare ELSE 0 END), 2) AS revenue,
  ROUND(100.0 * SUM(r.ride_status = 'cancelled') / COUNT(*), 2) AS cancellation_pct
FROM rides r
JOIN cities c ON r.city_id = c.city_id
GROUP BY c.city_name, c.tier
ORDER BY revenue DESC;

-- ---------------------------------------------------------------------
-- Q3. Monthly revenue and ride trend (identify growth / seasonality)
-- ---------------------------------------------------------------------
SELECT
  DATE_FORMAT(pickup_time, '%Y-%m') AS month,
  COUNT(*) AS rides,
  ROUND(SUM(total_fare), 2) AS revenue
FROM rides
WHERE ride_status = 'completed'
GROUP BY month
ORDER BY month;

-- ---------------------------------------------------------------------
-- Q4. Top 10 drivers by revenue generated (multi-table JOIN + ranking)
-- ---------------------------------------------------------------------
SELECT
  d.driver_id, d.name, d.city_id,
  COUNT(r.ride_id) AS rides_completed,
  ROUND(SUM(r.total_fare), 2) AS revenue_generated,
  d.rating
FROM rides r
JOIN drivers d ON r.driver_id = d.driver_id
WHERE r.ride_status = 'completed'
GROUP BY d.driver_id, d.name, d.city_id, d.rating
ORDER BY revenue_generated DESC
LIMIT 10;

-- ---------------------------------------------------------------------
-- Q5. Cancellation reasons — where is the platform losing rides?
-- ---------------------------------------------------------------------
SELECT cancellation_reason, COUNT(*) AS occurrences
FROM rides
WHERE ride_status = 'cancelled'
GROUP BY cancellation_reason
ORDER BY occurrences DESC;

-- ---------------------------------------------------------------------
-- Q6. Vehicle-type performance — which categories earn the most?
-- ---------------------------------------------------------------------
SELECT
  v.vehicle_type,
  COUNT(r.ride_id) AS rides,
  ROUND(AVG(r.total_fare), 2) AS avg_fare,
  ROUND(AVG(r.distance_km), 2) AS avg_distance_km
FROM rides r
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
WHERE r.ride_status = 'completed'
GROUP BY v.vehicle_type
ORDER BY rides DESC;

-- ---------------------------------------------------------------------
-- Q7. Peak demand hours (helps with driver supply planning)
-- ---------------------------------------------------------------------
SELECT HOUR(pickup_time) AS hour_of_day, COUNT(*) AS rides
FROM rides
GROUP BY hour_of_day
ORDER BY rides DESC
LIMIT 5;

-- ---------------------------------------------------------------------
-- Q8. Referral program impact — do referred users behave differently?
-- ---------------------------------------------------------------------
SELECT
  CASE WHEN referred_by_user_id IS NOT NULL THEN 'Referred' ELSE 'Organic' END AS acquisition_channel,
  COUNT(*) AS users,
  ROUND(AVG(total_rides), 1) AS avg_rides_per_user,
  ROUND(AVG(rating), 2) AS avg_rating
FROM users
GROUP BY acquisition_channel;

-- ---------------------------------------------------------------------
-- Q9. Coupon / campaign effectiveness
-- ---------------------------------------------------------------------
SELECT
  p.campaign_name,
  COUNT(*) AS times_used,
  ROUND(SUM(p.discount_amt), 2) AS total_discount_given,
  ROUND(AVG(r.total_fare), 2) AS avg_fare_on_discounted_rides
FROM promotions p
JOIN rides r ON p.ride_id = r.ride_id
GROUP BY p.campaign_name
ORDER BY times_used DESC;

-- ---------------------------------------------------------------------
-- Q10. Payment success / failure rate by mode (HAVING filters low-volume modes)
-- ---------------------------------------------------------------------
SELECT
  payment_mode,
  COUNT(*) AS transactions,
  ROUND(100.0 * SUM(payment_status = 'Success') / COUNT(*), 2) AS success_pct,
  ROUND(100.0 * SUM(payment_status = 'Failed')  / COUNT(*), 2) AS fail_pct
FROM payments
GROUP BY payment_mode
HAVING COUNT(*) > 100
ORDER BY transactions DESC;

-- ---------------------------------------------------------------------
-- Q11. Driver performance tiering with CASE logic (Gold/Silver/Bronze)
-- ---------------------------------------------------------------------
SELECT
  CASE
    WHEN acceptance_rate >= 90 AND cancellation_rate <= 5  THEN 'Gold'
    WHEN acceptance_rate >= 75 AND cancellation_rate <= 10 THEN 'Silver'
    ELSE 'Bronze'
  END AS driver_tier,
  COUNT(*) AS drivers,
  ROUND(AVG(rating), 2) AS avg_rating,
  ROUND(AVG(total_rides_completed), 0) AS avg_rides_completed
FROM drivers
GROUP BY driver_tier
ORDER BY drivers DESC;

-- ---------------------------------------------------------------------
-- Q12. Customer segmentation by ride frequency — CTE
-- ---------------------------------------------------------------------
WITH ride_counts AS (
  SELECT user_id, COUNT(*) AS n
  FROM rides
  WHERE ride_status = 'completed'
  GROUP BY user_id
)
SELECT
  CASE
    WHEN n = 1            THEN '1 ride'
    WHEN n BETWEEN 2 AND 5 THEN '2-5 rides'
    WHEN n BETWEEN 6 AND 15 THEN '6-15 rides'
    ELSE '15+ rides'
  END AS frequency_segment,
  COUNT(*) AS users,
  SUM(n) AS total_rides
FROM ride_counts
GROUP BY frequency_segment
ORDER BY users DESC;

-- ---------------------------------------------------------------------
-- Q13. City revenue ranking with a window function
-- ---------------------------------------------------------------------
SELECT
  city_name,
  revenue,
  RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
  ROUND(SUM(revenue) OVER (ORDER BY revenue DESC), 2) AS running_total
FROM (
  SELECT c.city_name, ROUND(SUM(r.total_fare), 2) AS revenue
  FROM rides r
  JOIN cities c ON r.city_id = c.city_id
  WHERE r.ride_status = 'completed'
  GROUP BY c.city_name
) city_revenue;

-- ---------------------------------------------------------------------
-- Q14. Most common ride feedback tags (service-quality signal)
-- ---------------------------------------------------------------------
SELECT feedback_tags, COUNT(*) AS occurrences
FROM ratings_feedback
WHERE feedback_tags IS NOT NULL AND feedback_tags <> ''
GROUP BY feedback_tags
ORDER BY occurrences DESC
LIMIT 8;

-- ---------------------------------------------------------------------
-- Q15. Drivers whose rating trails the platform average (subquery + anti-pattern check)
-- ---------------------------------------------------------------------
SELECT driver_id, name, city_id, rating, total_rides_completed
FROM drivers
WHERE rating < (SELECT AVG(rating) FROM drivers)
ORDER BY rating ASC
LIMIT 15;
