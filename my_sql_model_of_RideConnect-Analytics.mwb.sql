SET GLOBAL local_infile = 1;
CREATE DATABASE mobility_analytics;
USE mobility_analytics;

CREATE TABLE cities (
  city_id VARCHAR(10) PRIMARY KEY,
  city_name VARCHAR(50),
  state VARCHAR(50),
  tier VARCHAR(10)
);

CREATE TABLE users (
  user_id VARCHAR(15) PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(150),
  phone VARCHAR(15),
  signup_date DATE,
  city_id VARCHAR(10),
  device_type VARCHAR(20),
  preferred_payment_mode VARCHAR(20),
  wallet_balance DECIMAL(10,2),
  referral_code VARCHAR(20),
  referred_by_user_id VARCHAR(15),
  rating DECIMAL(3,2),
  is_active TINYINT,
  total_rides INT,
  last_ride_date DATE,
  FOREIGN KEY (city_id) REFERENCES cities(city_id),
  FOREIGN KEY (referred_by_user_id) REFERENCES users(user_id)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/Uday/Downloads/mobility_data/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(user_id, name, @email, @phone, signup_date, city_id, device_type,
 preferred_payment_mode, wallet_balance, referral_code, @referred_by_user_id,
 @rating, is_active, total_rides, @last_ride_date)
SET
  email = NULLIF(@email, ''),
  phone = NULLIF(@phone, ''),
  referred_by_user_id = NULLIF(@referred_by_user_id, ''),
  rating = NULLIF(@rating, ''),
  last_ride_date = NULLIF(@last_ride_date, '');
  
  SHOW GLOBAL VARIABLES LIKE 'local_infile';
  
  SHOW WARNINGS;
  
  
  select * from users;
  
  
  
  CREATE TABLE cities (
  city_id VARCHAR(10) PRIMARY KEY,
  city_name VARCHAR(50),
  state VARCHAR(50),
  tier VARCHAR(10)
);
select * from cities;

LOAD DATA LOCAL INFILE 'C:/Users/Uday/Downloads/mobility_data/cities.csv'
INTO TABLE cities
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from cities;



CREATE TABLE drivers (
  driver_id VARCHAR(15) PRIMARY KEY,
  name VARCHAR(100),
  phone VARCHAR(15),
  city_id VARCHAR(10),
  join_date DATE,
  license_number VARCHAR(20),
  vehicle_id VARCHAR(15),
  linked_user_id VARCHAR(15),
  rating DECIMAL(3,2),
  total_rides_completed INT,
  is_active TINYINT,
  background_check_status VARCHAR(20),
  weekly_hours_online DECIMAL(4,1),
  acceptance_rate DECIMAL(4,1),
  cancellation_rate DECIMAL(4,1),
  FOREIGN KEY (city_id) REFERENCES cities(city_id),
  FOREIGN KEY (linked_user_id) REFERENCES users(user_id)
);

LOAD DATA LOCAL INFILE "C:/Users/Uday/Downloads/mobility_data/drivers.csv"
INTO TABLE drivers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(driver_id, name, phone, city_id, join_date, license_number, vehicle_id,
 @linked_user_id, rating, total_rides_completed, is_active, @bg_status,
 weekly_hours_online, acceptance_rate, cancellation_rate)
SET
  linked_user_id = NULLIF(@linked_user_id, ''),
  background_check_status = NULLIF(@bg_status, '');
  
select * from drivers;

select 
	*
from users as u
join drivers as d
on u.user_id = d.linked_user_id;

-- select * from users;

CREATE TABLE vehicles (
  vehicle_id VARCHAR(15) PRIMARY KEY,
  driver_id VARCHAR(15),
  vehicle_type VARCHAR(20),
  make VARCHAR(50),
  model VARCHAR(50),
  year INT,
  registration_number VARCHAR(20),
  fuel_type VARCHAR(20),
  insurance_expiry_date DATE,
  last_service_date DATE,
  FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);


LOAD DATA LOCAL INFILE "C:/Users/Uday/Downloads/mobility_data/vehicles.csv"
INTO TABLE vehicles
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(vehicle_id, driver_id, vehicle_type, make, model, year,
 registration_number, fuel_type, insurance_expiry_date, @last_service_date)
SET last_service_date = NULLIF(@last_service_date, '');

ALTER TABLE drivers ADD CONSTRAINT fk_driver_vehicle
FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id);

select * from vehicles;




CREATE TABLE rides (
  ride_id VARCHAR(15) PRIMARY KEY,
  user_id VARCHAR(15),
  driver_id VARCHAR(15),
  vehicle_id VARCHAR(15),
  city_id VARCHAR(10),
  pickup_time DATETIME,
  drop_time DATETIME,
  distance_km DECIMAL(6,2),
  duration_min DECIMAL(6,1),
  base_fare DECIMAL(10,2),
  surge_multiplier DECIMAL(3,2),
  total_fare DECIMAL(10,2),
  payment_mode VARCHAR(20),
  ride_status VARCHAR(15),
  cancellation_reason VARCHAR(100),
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
  FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

LOAD DATA LOCAL INFILE "C:/Users/Uday/Downloads/mobility_data/rides.csv"
INTO TABLE rides
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ride_id, user_id, driver_id, vehicle_id, city_id, pickup_time,
 @drop_time, @distance_km, @duration_min, @base_fare, @surge_multiplier,
 total_fare, payment_mode, ride_status, @cancellation_reason)
SET
  drop_time = NULLIF(@drop_time, ''),
  distance_km = NULLIF(@distance_km, ''),
  duration_min = NULLIF(@duration_min, ''),
  base_fare = NULLIF(@base_fare, ''),
  surge_multiplier = NULLIF(@surge_multiplier, ''),
  cancellation_reason = NULLIF(@cancellation_reason, '');
  
  
select count(*) from rides;
select * from rides
join users
where rides.user_id = users.user_id;



CREATE TABLE payments (
  payment_id VARCHAR(15) PRIMARY KEY,
  ride_id VARCHAR(15),
  amount DECIMAL(10,2),
  payment_mode VARCHAR(20),
  payment_status VARCHAR(15),
  transaction_id VARCHAR(20),
  timestamp DATETIME,
  wallet_used TINYINT,
  cashback_applied DECIMAL(8,2),
  FOREIGN KEY (ride_id) REFERENCES rides(ride_id)
);

LOAD DATA LOCAL INFILE "C:/Users/Uday/Downloads/mobility_data/payments.csv"
INTO TABLE payments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(payment_id, ride_id, amount, payment_mode, payment_status,
 @transaction_id, timestamp, wallet_used, @cashback_applied)
SET
  transaction_id = NULLIF(@transaction_id, ''),
  cashback_applied = NULLIF(@cashback_applied, '');
  
  select * from payments;
  
  
  
  CREATE TABLE ratings_feedback (
  feedback_id VARCHAR(15) PRIMARY KEY,
  ride_id VARCHAR(15),
  user_rating DECIMAL(3,1),
  driver_rating DECIMAL(3,1),
  user_comment VARCHAR(255),
  driver_comment VARCHAR(255),
  feedback_tags VARCHAR(50),
  FOREIGN KEY (ride_id) REFERENCES rides(ride_id)
);

LOAD DATA LOCAL INFILE "C:/Users/Uday/Downloads/mobility_data/ratings_feedback.csv"
INTO TABLE ratings_feedback
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(feedback_id, ride_id, user_rating, @driver_rating, @user_comment,
 @driver_comment, @feedback_tags)
SET
  driver_rating = NULLIF(@driver_rating, ''),
  user_comment = NULLIF(@user_comment, ''),
  driver_comment = NULLIF(@driver_comment, ''),
  feedback_tags = NULLIF(@feedback_tags, '');
  
  
  select * from ratings_feedback;
  
  
  
CREATE TABLE promotions (
  coupon_id VARCHAR(15) PRIMARY KEY,
  ride_id VARCHAR(15),
  coupon_code VARCHAR(20),
  campaign_name VARCHAR(50),
  discount_type VARCHAR(15),
  discount_value DECIMAL(6,2),
  discount_amt DECIMAL(8,2),
  valid_from DATE,
  valid_to DATE,
  FOREIGN KEY (ride_id) REFERENCES rides(ride_id)
);

LOAD DATA LOCAL INFILE "C:/Users/Uday/Downloads/mobility_data/promotions.csv"
INTO TABLE promotions
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from promotions;

SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE CONSTRAINT_SCHEMA = 'mobility_analytics'
AND CONSTRAINT_NAME = 'fk_driver_vehicle';

SELECT 'cities' AS tbl, COUNT(*) AS rows_loaded FROM cities
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'drivers', COUNT(*) FROM drivers
UNION ALL SELECT 'vehicles', COUNT(*) FROM vehicles
UNION ALL SELECT 'rides', COUNT(*) FROM rides
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'ratings_feedback', COUNT(*) FROM ratings_feedback
UNION ALL SELECT 'promotions', COUNT(*) FROM promotions;




