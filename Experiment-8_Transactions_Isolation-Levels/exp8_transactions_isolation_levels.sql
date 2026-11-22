-- ============================================================
-- Experiment 8 : Transactions, Savepoints and Isolation Levels
-- Banking-style transactions using START TRANSACTION, COMMIT,
-- ROLLBACK and SAVEPOINT; partial-failure simulation; isolation
-- levels and a concurrency anomaly demonstrated with two sessions
-- Requires MySQL 8.0 or later (InnoDB)
-- ============================================================

-- STEP 0: REMOVE OLD TABLE IF IT EXISTS
DROP TABLE IF EXISTS Accounts;

-- ------------------------------------------------------------
-- STEP 1: CREATE BANKING TABLE
-- ------------------------------------------------------------
CREATE TABLE Accounts (
    Account_ID  INT PRIMARY KEY,
    Holder_Name VARCHAR(50),
    Balance     DECIMAL(10,2)
);

INSERT INTO Accounts VALUES
(101, 'Amit',  10000),
(102, 'Rahul', 8000);

SELECT * FROM Accounts;      -- 101: 10000.00 | 102: 8000.00

-- ------------------------------------------------------------
-- STEP 2: START TRANSACTION and COMMIT (transfer 2000 from 101 to 102)
-- ------------------------------------------------------------
START TRANSACTION;

UPDATE Accounts
SET Balance = Balance - 2000
WHERE Account_ID = 101;

UPDATE Accounts
SET Balance = Balance + 2000
WHERE Account_ID = 102;

COMMIT;

SELECT * FROM Accounts;      -- 101: 8000.00 | 102: 10000.00

-- ------------------------------------------------------------
-- STEP 3: ROLLBACK (the withdrawal is undone)
-- ------------------------------------------------------------
START TRANSACTION;

UPDATE Accounts
SET Balance = Balance - 5000
WHERE Account_ID = 101;

ROLLBACK;

SELECT * FROM Accounts;      -- unchanged: 8000.00 | 10000.00

-- ------------------------------------------------------------
-- STEP 4: SAVEPOINT (partial rollback inside a transaction)
-- ------------------------------------------------------------
START TRANSACTION;

UPDATE Accounts
SET Balance = Balance - 1000
WHERE Account_ID = 101;

SAVEPOINT sp1;

UPDATE Accounts
SET Balance = Balance - 20000
WHERE Account_ID = 102;

ROLLBACK TO SAVEPOINT sp1;   -- undoes only the 20000 deduction

COMMIT;                      -- keeps the 1000 deduction

SELECT * FROM Accounts;      -- 101: 7000.00 | 102: 10000.00

-- ------------------------------------------------------------
-- STEP 5: PARTIAL FAILURE SIMULATION
-- The second UPDATE targets a non-existent account (999), so the
-- transfer is incomplete and the whole transaction is rolled back.
-- ------------------------------------------------------------
START TRANSACTION;

UPDATE Accounts
SET Balance = Balance - 500
WHERE Account_ID = 101;

-- Simulated failure: invalid account (0 rows affected)
UPDATE Accounts
SET Balance = Balance + 500
WHERE Account_ID = 999;

ROLLBACK;

SELECT * FROM Accounts;      -- unchanged: 7000.00 | 10000.00

-- ------------------------------------------------------------
-- STEP 6: ISOLATION LEVELS
-- (SET TRANSACTION applies to the next transaction only)
-- ------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM Accounts;
COMMIT;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM Accounts;
COMMIT;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT * FROM Accounts;
COMMIT;

-- ------------------------------------------------------------
-- STEP 7: CONCURRENCY ANOMALY (run in TWO separate sessions/windows)
-- Execute the statements in the order shown by the step numbers.
-- ------------------------------------------------------------

-- SESSION 1  (step 1)
START TRANSACTION;
SELECT Balance FROM Accounts
WHERE Account_ID = 101;                -- reads 7000.00

-- SESSION 2  (step 2)
START TRANSACTION;
UPDATE Accounts
SET Balance = Balance - 500
WHERE Account_ID = 101;
COMMIT;

-- SESSION 1  (step 3)
SELECT Balance FROM Accounts
WHERE Account_ID = 101;
COMMIT;

-- Tip: to observe a non-repeatable read, run SESSION 1 under
--   SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- before its START TRANSACTION. Under MySQL's default REPEATABLE READ the
-- second SELECT in Session 1 keeps returning the original snapshot value.

SELECT * FROM Accounts;      -- 101: 6500.00 | 102: 10000.00
