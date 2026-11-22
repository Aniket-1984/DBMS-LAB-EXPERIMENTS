-- ============================================================
-- Experiment 10 : Query Optimization
-- Dataset of 10,000 rows; five slow queries analysed with EXPLAIN,
-- optimized with indexing and query rewriting
-- Requires MySQL 8.0 or later
-- ============================================================

-- STEP 0: REMOVE OLD OBJECTS IF THEY EXIST
DROP PROCEDURE IF EXISTS GenerateEmployees;
DROP TABLE IF EXISTS Employees;

-- ------------------------------------------------------------
-- STEP 1: CREATE EMPLOYEE TABLE
-- ------------------------------------------------------------
CREATE TABLE Employees (
    Emp_ID       INT PRIMARY KEY,
    Emp_Name     VARCHAR(50),
    Department   VARCHAR(30),
    City         VARCHAR(30),
    Salary       DECIMAL(10,2),
    Joining_Date DATE
);

-- ------------------------------------------------------------
-- STEP 2: GENERATE 10,000 RECORDS USING A STORED PROCEDURE
-- ------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE GenerateEmployees()
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= 10000 DO
        INSERT INTO Employees VALUES (
            i,
            CONCAT('Employee_', i),
            ELT((i % 5) + 1, 'IT', 'HR', 'Sales', 'Finance', 'Marketing'),
            ELT((i % 4) + 1, 'Delhi', 'Mumbai', 'Lucknow', 'Pune'),
            20000 + (i % 50000),
            DATE_ADD('2020-01-01', INTERVAL (i % 2000) DAY)
        );

        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

CALL GenerateEmployees();

SELECT * FROM Employees;

-- ------------------------------------------------------------
-- STEP 3: FIVE SLOW QUERIES (before optimization, full scans)
-- ------------------------------------------------------------

-- Query 1: Search by Department
EXPLAIN SELECT * FROM Employees
WHERE Department = 'IT';

-- Query 2: Search by City
EXPLAIN SELECT * FROM Employees
WHERE City = 'Delhi';

-- Query 3: Salary Filtering
EXPLAIN SELECT * FROM Employees
WHERE Salary > 50000;

-- Query 4: Multiple Conditions
EXPLAIN SELECT * FROM Employees
WHERE Department = 'Sales'
  AND City = 'Mumbai';

-- Query 5: Sorting and Filtering
EXPLAIN SELECT * FROM Employees
WHERE Department = 'HR'
ORDER BY Salary DESC;

-- ------------------------------------------------------------
-- STEP 4: OPTIMIZATION USING INDEXING
-- ------------------------------------------------------------
CREATE INDEX idx_department
ON Employees(Department);

CREATE INDEX idx_city
ON Employees(City);

CREATE INDEX idx_salary
ON Employees(Salary);

CREATE INDEX idx_dept_city
ON Employees(Department, City);

CREATE INDEX idx_dept_salary
ON Employees(Department, Salary);

-- ------------------------------------------------------------
-- STEP 5: OPTIMIZED QUERIES (same queries, now using indexes)
-- ------------------------------------------------------------

-- Query 1
EXPLAIN SELECT * FROM Employees
WHERE Department = 'IT';

-- Query 2
EXPLAIN SELECT * FROM Employees
WHERE City = 'Delhi';

-- Query 3
EXPLAIN SELECT * FROM Employees
WHERE Salary > 50000;

-- Query 4
EXPLAIN SELECT * FROM Employees
WHERE Department = 'Sales'
  AND City = 'Mumbai';

-- Query 5
EXPLAIN SELECT * FROM Employees
WHERE Department = 'HR'
ORDER BY Salary DESC;

-- ------------------------------------------------------------
-- STEP 6: QUERY REWRITING EXAMPLE
-- A function on the column (YEAR(...)) prevents index use;
-- an equivalent range condition is index-friendly (sargable).
-- ------------------------------------------------------------

-- Before optimization
SELECT * FROM Employees
WHERE YEAR(Joining_Date) = 2022;

-- After optimization
SELECT * FROM Employees
WHERE Joining_Date >= '2022-01-01'
  AND Joining_Date <  '2023-01-01';

-- Index for date search
CREATE INDEX idx_joining_date
ON Employees(Joining_Date);

-- Optional: compare the plans and actual execution time (MySQL 8.0.18+)
-- EXPLAIN SELECT * FROM Employees WHERE YEAR(Joining_Date) = 2022;
-- EXPLAIN SELECT * FROM Employees
--   WHERE Joining_Date >= '2022-01-01' AND Joining_Date < '2023-01-01';
-- EXPLAIN ANALYZE SELECT * FROM Employees
--   WHERE Joining_Date >= '2022-01-01' AND Joining_Date < '2023-01-01';

-- ------------------------------------------------------------
-- STEP 7: CHECK FINAL DATASET
-- ------------------------------------------------------------
SELECT COUNT(*) AS Total_Records
FROM Employees;     -- 10000
