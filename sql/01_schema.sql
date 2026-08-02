-- =====================================================================
-- RideConnect Analytics — Multi-Modal Mobility Data Warehouse
-- 01_schema.sql
--
-- Creates the database and all 8 tables in the correct dependency order
-- (parent tables before child tables) so foreign keys never fail.
--
-- Load order for reference: cities -> users -> drivers -> vehicles
--                            -> rides -> payments -> ratings_feedback
--                            -> promotions
-- =====================================================================

DROP DATABASE IF EXISTS mobility_analytics;
CREATE DATABASE mobility_analytics;
USE mobility_analytics;

-- ---------------------------------------------------------------------
-- 1. CITIES  (dimension — no dependencies)
-- ---------------------------------------------------------------------
CREATE TABLE cities (
  city_id     VARCHAR(10) PRIMARY KEY,
  city_name   VARCHAR(50),
  state       VARCHAR(50),
  tier        VARCHAR(10)
);

-- ---------------------------------------------------------------------
-- 2. USERS  (depends on cities; self-references itself via referral)
-- ---------------------------------------------------------------------
CREATE TABLE users (
  user_id                 VARCHAR(15) PRIMARY KEY,
  name                    VARCHAR(100),
  email                   VARCHAR(150),
  phone                   VARCHAR(15),
  signup_date             DATE,
  city_id                 VARCHAR(10),
  device_type             VARCHAR(20),
  preferred_payment_mode  VARCHAR(20),
  wallet_balance          DECIMAL(10,2),
  referral_code           VARCHAR(20),
  referred_by_user_id     VARCHAR(15),
  rating                  DECIMAL(3,2),
  is_active               TINYINT,
  total_rides             INT,
  last_ride_date          DATE,
  CONSTRAINT fk_users_city
      FOREIGN KEY (city_id) REFERENCES cities(city_id),
  CONSTRAINT fk_users_referrer
      FOREIGN KEY (referred_by_user_id) REFERENCES users(user_id)
);

-- ---------------------------------------------------------------------
-- 3. DRIVERS  (depends on cities and users; vehicle_id FK added later
--    because drivers <-> vehicles is a circular reference)
-- ---------------------------------------------------------------------
CREATE TABLE drivers (
  driver_id                 VARCHAR(15) PRIMARY KEY,
  name                      VARCHAR(100),
  phone                     VARCHAR(15),
  city_id                   VARCHAR(10),
  join_date                 DATE,
  license_number            VARCHAR(20),
  vehicle_id                VARCHAR(15),
  linked_user_id            VARCHAR(15),
  rating                    DECIMAL(3,2),
  total_rides_completed     INT,
  is_active                 TINYINT,
  background_check_status   VARCHAR(20),
  weekly_hours_online       DECIMAL(4,1),
  acceptance_rate           DECIMAL(4,1),
  cancellation_rate         DECIMAL(4,1),
  CONSTRAINT fk_drivers_city
      FOREIGN KEY (city_id) REFERENCES cities(city_id),
  CONSTRAINT fk_drivers_user
      FOREIGN KEY (linked_user_id) REFERENCES users(user_id)
);

-- ---------------------------------------------------------------------
-- 4. VEHICLES  (depends on drivers)
-- ---------------------------------------------------------------------
CREATE TABLE vehicles (
  vehicle_id             VARCHAR(15) PRIMARY KEY,
  driver_id              VARCHAR(15),
  vehicle_type           VARCHAR(20),
  make                   VARCHAR(50),
  model                  VARCHAR(50),
  year                   INT,
  registration_number    VARCHAR(20),
  fuel_type              VARCHAR(20),
  insurance_expiry_date  DATE,
  last_service_date      DATE,
  CONSTRAINT fk_vehicles_driver
      FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

-- Close the circular reference: each driver's assigned vehicle
ALTER TABLE drivers
  ADD CONSTRAINT fk_drivers_vehicle
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id);

-- ---------------------------------------------------------------------
-- 5. RIDES  (fact table — depends on users, drivers, vehicles, cities)
-- ---------------------------------------------------------------------
CREATE TABLE rides (
  ride_id             VARCHAR(15) PRIMARY KEY,
  user_id             VARCHAR(15),
  driver_id           VARCHAR(15),
  vehicle_id          VARCHAR(15),
  city_id             VARCHAR(10),
  pickup_time         DATETIME,
  drop_time           DATETIME,
  distance_km         DECIMAL(6,2),
  duration_min        DECIMAL(6,1),
  base_fare           DECIMAL(10,2),
  surge_multiplier    DECIMAL(3,2),
  total_fare          DECIMAL(10,2),
  payment_mode        VARCHAR(20),
  ride_status         VARCHAR(15),
  cancellation_reason VARCHAR(100),
  CONSTRAINT fk_rides_user    FOREIGN KEY (user_id)    REFERENCES users(user_id),
  CONSTRAINT fk_rides_driver  FOREIGN KEY (driver_id)  REFERENCES drivers(driver_id),
  CONSTRAINT fk_rides_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
  CONSTRAINT fk_rides_city    FOREIGN KEY (city_id)    REFERENCES cities(city_id)
);

-- ---------------------------------------------------------------------
-- 6. PAYMENTS  (depends on rides)
-- ---------------------------------------------------------------------
CREATE TABLE payments (
  payment_id       VARCHAR(15) PRIMARY KEY,
  ride_id          VARCHAR(15),
  amount           DECIMAL(10,2),
  payment_mode     VARCHAR(20),
  payment_status   VARCHAR(15),
  transaction_id   VARCHAR(20),
  timestamp        DATETIME,
  wallet_used      TINYINT,
  cashback_applied DECIMAL(8,2),
  CONSTRAINT fk_payments_ride FOREIGN KEY (ride_id) REFERENCES rides(ride_id)
);

-- ---------------------------------------------------------------------
-- 7. RATINGS_FEEDBACK  (depends on rides)
-- ---------------------------------------------------------------------
CREATE TABLE ratings_feedback (
  feedback_id     VARCHAR(15) PRIMARY KEY,
  ride_id         VARCHAR(15),
  user_rating     DECIMAL(3,1),
  driver_rating   DECIMAL(3,1),
  user_comment    VARCHAR(255),
  driver_comment  VARCHAR(255),
  feedback_tags   VARCHAR(50),
  CONSTRAINT fk_feedback_ride FOREIGN KEY (ride_id) REFERENCES rides(ride_id)
);

-- ---------------------------------------------------------------------
-- 8. PROMOTIONS  (depends on rides)
-- ---------------------------------------------------------------------
CREATE TABLE promotions (
  coupon_id       VARCHAR(15) PRIMARY KEY,
  ride_id         VARCHAR(15),
  coupon_code     VARCHAR(20),
  campaign_name   VARCHAR(50),
  discount_type   VARCHAR(15),
  discount_value  DECIMAL(6,2),
  discount_amt    DECIMAL(8,2),
  valid_from      DATE,
  valid_to        DATE,
  CONSTRAINT fk_promotions_ride FOREIGN KEY (ride_id) REFERENCES rides(ride_id)
);
