# Experiment 10 — Query Optimization: Indexing and Query Rewriting

**Name:** ANIKET &nbsp;|&nbsp; **Roll No:** 25LBCS3174

## Aim

To generate a dataset with at least **10,000 rows**, write **five slow queries**, analyze them using `EXPLAIN`, optimize them using **indexing and query rewriting**, and compare the execution plans before and after optimization.

## Description

Query optimization reduces the amount of work the database does to answer a query. `EXPLAIN` shows the execution plan: the access type (`ALL` = full table scan, `ref`/`range` = index access), the index chosen, the estimated number of rows examined, and extra information such as `Using filesort`.

A stored procedure generates **10,000 employees** spread over 5 departments, 4 cities, a range of salaries and joining dates. Five typical queries (single-column filter, range filter, multi-column filter, and filter with sorting) are first run without indexes — each one scans all rows. Single-column and composite indexes are then created, and the same queries are explained again.

**Query rewriting** is demonstrated with a date filter: `WHERE YEAR(Joining_Date) = 2022` applies a function to the column and so cannot use an index on `Joining_Date`; the equivalent range condition `Joining_Date >= '2022-01-01' AND Joining_Date < '2023-01-01'` is *sargable* and can use the index.

> The following SQL uses **MySQL 8.0 or later**.

## Files

| File | Description |
|------|-------------|
| [`exp10_query_optimization.sql`](exp10_query_optimization.sql) | Complete SQL code base (table + data generator + 5 queries + indexes + rewrite) |
| [`ANIKET10.pdf`](ANIKET10.pdf) | Original lab record PDF |
| [`outputs/`](outputs/) | Output screenshots |

## Schema

- **Employees** (`Emp_ID` PK, `Emp_Name`, `Department`, `City`, `Salary`, `Joining_Date`)

Indexes created: `idx_department`, `idx_city`, `idx_salary`, `idx_dept_city (Department, City)`, `idx_dept_salary (Department, Salary)` and `idx_joining_date`.

## Source Code

The full code is in [`exp10_query_optimization.sql`](exp10_query_optimization.sql). Key statements:

### 1. Create the table and generate 10,000 records

```sql
CREATE TABLE Employees (
    Emp_ID INT PRIMARY KEY,
    Emp_Name VARCHAR(50),
    Department VARCHAR(30),
    City VARCHAR(30),
    Salary DECIMAL(10,2),
    Joining_Date DATE
);

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
```

### 2. Five slow queries (analysed with EXPLAIN)

```sql
-- Query 1: Search by Department
EXPLAIN SELECT * FROM Employees WHERE Department = 'IT';

-- Query 2: Search by City
EXPLAIN SELECT * FROM Employees WHERE City = 'Delhi';

-- Query 3: Salary Filtering
EXPLAIN SELECT * FROM Employees WHERE Salary > 50000;

-- Query 4: Multiple Conditions
EXPLAIN SELECT * FROM Employees
WHERE Department = 'Sales' AND City = 'Mumbai';

-- Query 5: Sorting and Filtering
EXPLAIN SELECT * FROM Employees
WHERE Department = 'HR'
ORDER BY Salary DESC;
```

### 3. Optimization using indexing

```sql
CREATE INDEX idx_department  ON Employees(Department);
CREATE INDEX idx_city        ON Employees(City);
CREATE INDEX idx_salary      ON Employees(Salary);
CREATE INDEX idx_dept_city   ON Employees(Department, City);
CREATE INDEX idx_dept_salary ON Employees(Department, Salary);
```

### 4. Query rewriting

```sql
-- Before optimization (function on the column prevents index use)
SELECT * FROM Employees
WHERE YEAR(Joining_Date) = 2022;

-- After optimization (range condition can use an index)
SELECT * FROM Employees
WHERE Joining_Date >= '2022-01-01'
  AND Joining_Date <  '2023-01-01';

CREATE INDEX idx_joining_date
ON Employees(Joining_Date);
```

## EXPLAIN Comparison

| Query | Before: type / rows | After: type / key | After: rows examined |
|-------|---------------------|-------------------|---------------------:|
| 1. `Department = 'IT'` | `ALL` / 9948 | `ref` / `idx_department` | 2000 |
| 2. `City = 'Delhi'` | `ALL` / 9948 | `ref` / `idx_city` | 2500 |
| 3. `Salary > 50000` | `ALL` / 9948 | `range` / `idx_salary` (Using index condition) | 1 |
| 4. `Department = 'Sales' AND City = 'Mumbai'` | `ALL` / 9948 | `ref` / `idx_dept_city` | ~500* |
| 5. `Department = 'HR' ORDER BY Salary DESC` | `ALL` / 9948, **Using filesort** | `ref` / `idx_dept_salary` | 2000 |

\* The `rows` value for Query 4 is cut off at the edge of the screenshot; about 500 rows is what the data distribution gives (10,000 rows ÷ 20 department–city combinations).

- Every query changes from a **full table scan** (`ALL`, ~9948 rows) to an **index lookup** (`ref` / `range`).
- Query 4 uses the composite index `idx_dept_city` (`key_len` 246 = both columns), which is far more selective than `idx_department` alone.
- Query 5 uses `idx_dept_salary`, which already stores each department's rows in salary order, so the **`Using filesort` step seen before optimization is no longer needed** (the `Extra` column is cut off in the after-optimization screenshot, so re-run `EXPLAIN` to confirm).
- In the generated data the salaries range from 20,001 to 30,000, so Query 3 (`Salary > 50000`) matches no rows — the optimizer's estimate of 1 row reflects this.

## Output

### Dataset

![Generated Dataset](outputs/01_generated_employee_dataset.png)

### Five slow queries — before optimization

| Query | Screenshot |
|-------|------------|
| 1. Department | ![Q1 Before](outputs/02_q1_before_department.png) |
| 2. City | ![Q2 Before](outputs/03_q2_before_city.png) |
| 3. Salary | ![Q3 Before](outputs/04_q3_before_salary.png) |
| 4. Department + City | ![Q4 Before](outputs/05_q4_before_department_city.png) |
| 5. Department + ORDER BY Salary | ![Q5 Before](outputs/06_q5_before_department_order_by_salary.png) |

### Indexing and optimization

![Index Creation](outputs/07_index_creation.png)

### Five optimized queries — after optimization

| Query | Screenshot |
|-------|------------|
| 1. Department | ![Q1 After](outputs/08_q1_after_department.png) |
| 2. City | ![Q2 After](outputs/09_q2_after_city.png) |
| 3. Salary | ![Q3 After](outputs/10_q3_after_salary.png) |
| 4. Department + City | ![Q4 After](outputs/11_q4_after_department_city.png) |
| 5. Department + ORDER BY Salary | ![Q5 After](outputs/12_q5_after_department_order_by_salary.png) |

### Query rewriting — before (`YEAR()` function)

![Rewrite Before](outputs/13_rewrite_before_year_function.png)

### Query rewriting — after (range condition)

![Rewrite After](outputs/14_rewrite_after_range_condition.png)

### Final table

![Final Table](outputs/15_final_table.png)

## Notes

- Both forms of the date query return the same rows (employees who joined in 2022); the rewrite only changes how efficiently they are found. Because `idx_joining_date` is created after the rewrite example in the script, run the optional `EXPLAIN` / `EXPLAIN ANALYZE` lines at the end of the `.sql` file to compare the two plans and the real execution time.
- This lab record compares execution **plans**. Actual execution time can be added with `EXPLAIN ANALYZE` (MySQL 8.0.18+).

## Result

A dataset of 10,000 employee records was generated. Five slow queries that performed full table scans (about 9948 rows examined) were optimized using single-column and composite indexes, which turned them into index lookups and let the sorted query read rows in index order instead of using a filesort. A query rewrite replaced `YEAR(Joining_Date) = 2022` with an index-friendly date range.
