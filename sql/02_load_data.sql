-- =====================================================================
-- RideConnect Analytics — Multi-Modal Mobility Data Warehouse
-- 02_load_data.sql
--
-- Loads all 8 CSVs from the /data folder into MySQL via LOAD DATA LOCAL INFILE.
-- Run 01_schema.sql FIRST. Tables must be loaded in this exact order —
-- parents before children — or you will hit Error 1452 (FK constraint fails).
--
-- BEFORE RUNNING:
-- 1) Enable local_infile on both the server and client:
--      SET GLOBAL local_infile = 1;
--    In MySQL Workbench: Database > Manage Connections > Advanced >
--      Others: OPT_LOCAL_INFILE=1
-- 2) Replace the placeholder path below with the actual folder where you
--    downloaded this repo's /data CSVs, e.g.
--      'C:/Users/<you>/Downloads/RideConnect-Analytics/data/cities.csv'
--    MySQL needs forward slashes even on Windows.
-- =====================================================================

USE mobility_analytics;
SET GLOBAL local_infile = 1;

-- ---------------------------------------------------------------------
-- 1. CITIES
-- ---------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'REPLACE_WITH_YOUR_PATH/data/cities.csv'
INTO TABLE cities
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS cities_loaded FROM cities;

-- ---------------------------------------------------------------------
-- 2. USERS
-- ---------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'REPLACE_WITH_YOUR_PATH/data/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(user_id, name, @email, @phone, signup_date, city_id, device_type,
 preferred_payment_mode, wallet_balance, referral_code, @referred_by_user_id,
 @rating, is_active, total_rides, @last_ride_date)
SET
  email               = NULLIF(@email, ''),
  phone               = NULLIF(@phone, ''),
  referred_by_user_id = NULLIF(@referred_by_user_id, ''),
  rating              = NULLIF(@rating, ''),
  last_ride_date      = NULLIF(@last_ride_date, '');

SELECT COUNT(*) AS users_loaded FROM users;

-- ---------------------------------------------------------------------
-- 3. DRIVERS
-- ---------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'REPLACE_WITH_YOUR_PATH/data/drivers.csv'
INTO TABLE drivers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(driver_id, name, phone, city_id, join_date, license_number, vehicle_id,
 @linked_user_id, rating, total_rides_completed, is_active, @bg_status,
 weekly_hours_online, acceptance_rate, cancellation_rate)
SET
  linked_user_id           = NULLIF(@linked_user_id, ''),
  background_check_status  = NULLIF(@bg_status, '');

SELECT COUNT(*) AS drivers_loaded FROM drivers;

-- ---------------------------------------------------------------------
-- 4. VEHICLES
-- ---------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'REPLACE_WITH_YOUR_PATH/data/vehicles.csv'
INTO TABLE vehicles
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(vehicle_id, driver_id, vehicle_type, make, model, year,
 registration_number, fuel_type, insurance_expiry_date, @last_service_date)
SET last_service_date = NULLIF(@last_service_date, '');

SELECT COUNT(*) AS vehicles_loaded FROM vehicles;

-- ---------------------------------------------------------------------
-- 5. RIDES
-- ---------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'REPLACE_WITH_YOUR_PATH/data/rides.csv'
INTO TABLE rides
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ride_id, user_id, driver_id, vehicle_id, city_id, pickup_time,
 @drop_time, @distance_km, @duration_min, @base_fare, @surge_multiplier,
 total_fare, payment_mode, ride_status, @cancellation_reason)
SET
  drop_time           = NULLIF(@drop_time, ''),
  distance_km         = NULLIF(@distance_km, ''),
  duration_min        = NULLIF(@duration_min, ''),
  base_fare           = NULLIF(@base_fare, ''),
  surge_multiplier    = NULLIF(@surge_multiplier, ''),
  cancellation_reason = NULLIF(@cancellation_reason, '');

SELECT COUNT(*) AS rides_loaded FROM rides;

-- ---------------------------------------------------------------------
-- 6. PAYMENTS
-- ---------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'REPLACE_WITH_YOUR_PATH/data/payments.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(payment_id, ride_id, amount, payment_mode, payment_status,
 @transaction_id, timestamp, wallet_used, @cashback_applied)
SET
  transaction_id    = NULLIF(@transaction_id, ''),
  cashback_applied  = NULLIF(@cashback_applied, '');

SELECT COUNT(*) AS payments_loaded FROM payments;

-- ---------------------------------------------------------------------
-- 7. RATINGS_FEEDBACK
-- ---------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'REPLACE_WITH_YOUR_PATH/data/ratings_feedback.csv'
INTO TABLE ratings_feedback
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(feedback_id, ride_id, user_rating, @driver_rating, @user_comment,
 @driver_comment, @feedback_tags)
SET
  driver_rating  = NULLIF(@driver_rating, ''),
  user_comment   = NULLIF(@user_comment, ''),
  driver_comment = NULLIF(@driver_comment, ''),
  feedback_tags  = NULLIF(@feedback_tags, '');

SELECT COUNT(*) AS ratings_feedback_loaded FROM ratings_feedback;

-- ---------------------------------------------------------------------
-- 8. PROMOTIONS
-- ---------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'REPLACE_WITH_YOUR_PATH/data/promotions.csv'
INTO TABLE promotions
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS promotions_loaded FROM promotions;

-- ---------------------------------------------------------------------
-- Final sanity check — expected row counts
-- ---------------------------------------------------------------------
SELECT 'cities' AS tbl, COUNT(*) AS rows_loaded FROM cities
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'drivers', COUNT(*) FROM drivers
UNION ALL SELECT 'vehicles', COUNT(*) FROM vehicles
UNION ALL SELECT 'rides', COUNT(*) FROM rides
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'ratings_feedback', COUNT(*) FROM ratings_feedback
UNION ALL SELECT 'promotions', COUNT(*) FROM promotions;
