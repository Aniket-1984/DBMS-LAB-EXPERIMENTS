-- ============================================================
-- Experiment 9 : Indexing and Query Performance
-- Railway_Booking table with 5,000 records; compare query
-- performance and EXPLAIN plans before and after creating a
-- single-column index and a composite index
-- Requires MySQL 8.0 or later
-- ============================================================

-- STEP 0: REMOVE OLD OBJECTS IF THEY EXIST
DROP PROCEDURE IF EXISTS InsertBookings;
DROP TABLE IF EXISTS Railway_Booking;

-- ------------------------------------------------------------
-- STEP 1: CREATE RAILWAY BOOKING TABLE
-- ------------------------------------------------------------
CREATE TABLE Railway_Booking (
    Booking_ID     INT PRIMARY KEY,
    Passenger_Name VARCHAR(50),
    Train_No       INT,
    Source         VARCHAR(50),
    Destination    VARCHAR(50),
    Journey_Date   DATE,
    Seat_No        INT,
    Fare           DECIMAL(10,2)
);

-- ------------------------------------------------------------
-- STEP 2: INSERT 5000 RECORDS USING A STORED PROCEDURE
-- ------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE InsertBookings()
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= 5000 DO
        INSERT INTO Railway_Booking VALUES (
            i,
            CONCAT('Passenger_', i),
            12000 + (i % 20),
            'Delhi',
            'Lucknow',
            DATE_ADD('2026-01-01', INTERVAL (i % 365) DAY),
            i % 100,
            500 + (i % 1500)
        );

        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

CALL InsertBookings();

SELECT * FROM Railway_Booking;
SELECT COUNT(*) AS total_bookings FROM Railway_Booking;   -- 5000

-- ------------------------------------------------------------
-- STEP 3: QUERY BEFORE INDEXING (full table scan, type = ALL)
-- ------------------------------------------------------------
EXPLAIN SELECT * FROM Railway_Booking
WHERE Train_No = 12005;

-- ------------------------------------------------------------
-- STEP 4: SINGLE COLUMN INDEX
-- ------------------------------------------------------------
CREATE INDEX idx_train
ON Railway_Booking(Train_No);

EXPLAIN SELECT * FROM Railway_Booking
WHERE Train_No = 12005;

-- ------------------------------------------------------------
-- STEP 5: COMPOSITE INDEX
-- ------------------------------------------------------------
CREATE INDEX idx_train_date
ON Railway_Booking(Train_No, Journey_Date);

EXPLAIN SELECT * FROM Railway_Booking
WHERE Train_No = 12005
  AND Journey_Date = '2026-03-15';

-- ------------------------------------------------------------
-- STEP 6: PERFORMANCE COMPARISON (actual query results)
-- ------------------------------------------------------------
SELECT * FROM Railway_Booking
WHERE Train_No = 12005;

-- Returns no rows: no generated booking has both Train_No 12005
-- and Journey_Date 2026-03-15 (this is expected, not an error)
SELECT * FROM Railway_Booking
WHERE Train_No = 12005
  AND Journey_Date = '2026-03-15';

-- Optional: measure actual execution time (MySQL 8.0.18+)
-- EXPLAIN ANALYZE SELECT * FROM Railway_Booking WHERE Train_No = 12005;
-- EXPLAIN ANALYZE SELECT * FROM Railway_Booking
--   WHERE Train_No = 12005 AND Journey_Date = '2026-03-15';

-- ------------------------------------------------------------
-- STEP 7: FINAL TABLE
-- ------------------------------------------------------------
SELECT * FROM Railway_Booking;
