# Experiment 8 — Transactions, Savepoints and Isolation Levels

**Name:** ANIKET &nbsp;|&nbsp; **Roll No:** 25LBCS3174

## Aim

To implement banking-style transactions using `START TRANSACTION` (BEGIN), `COMMIT`, `ROLLBACK` and `SAVEPOINT`, simulate partial failures, and demonstrate **isolation levels** and a **concurrency anomaly** using two sessions.

## Description

A **transaction** is a group of SQL statements executed as one unit that follows the ACID properties. In a bank transfer, the debit and the credit must either both succeed or both be undone.

- **COMMIT** makes all changes of the transaction permanent.
- **ROLLBACK** undoes all changes made since the transaction started.
- **SAVEPOINT** marks a point inside a transaction; `ROLLBACK TO SAVEPOINT` undoes only the work done after that point.
- **Isolation levels** (`READ COMMITTED`, `REPEATABLE READ`, `SERIALIZABLE`) control how far one transaction is isolated from the uncommitted or newly committed changes of another.

A partial failure is simulated by a transfer whose credit step targets an account that does not exist; the whole transaction is rolled back so that money is not lost. Finally, two sessions are used to show how a committed update by one session affects a transaction running in another.

> The following SQL uses **MySQL 8.0 or later** with the InnoDB engine.

## Files

| File | Description |
|------|-------------|
| [`exp8_transactions_isolation_levels.sql`](exp8_transactions_isolation_levels.sql) | Complete SQL code base (table + all transaction scenarios + two-session demo) |
| [`ANIKET08.pdf`](ANIKET08.pdf) | Original lab record PDF |
| [`outputs/`](outputs/) | Output screenshots |

## Schema

- **Accounts** (`Account_ID` PK, `Holder_Name`, `Balance`)

Sample data: account 101 (Amit, 10000) and account 102 (Rahul, 8000).

## Source Code

The full code is in [`exp8_transactions_isolation_levels.sql`](exp8_transactions_isolation_levels.sql). Key scenarios:

### 1. START TRANSACTION and COMMIT — transfer 2000 from 101 to 102

```sql
START TRANSACTION;

UPDATE Accounts SET Balance = Balance - 2000 WHERE Account_ID = 101;
UPDATE Accounts SET Balance = Balance + 2000 WHERE Account_ID = 102;

COMMIT;
```

### 2. ROLLBACK

```sql
START TRANSACTION;

UPDATE Accounts SET Balance = Balance - 5000 WHERE Account_ID = 101;

ROLLBACK;
```

### 3. SAVEPOINT

```sql
START TRANSACTION;

UPDATE Accounts SET Balance = Balance - 1000 WHERE Account_ID = 101;
SAVEPOINT sp1;

UPDATE Accounts SET Balance = Balance - 20000 WHERE Account_ID = 102;
ROLLBACK TO SAVEPOINT sp1;

COMMIT;
```

### 4. Partial failure simulation

```sql
START TRANSACTION;

UPDATE Accounts SET Balance = Balance - 500 WHERE Account_ID = 101;

-- Simulated failure: invalid account
UPDATE Accounts SET Balance = Balance + 500 WHERE Account_ID = 999;

ROLLBACK;
```

### 5. Isolation levels

```sql
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
```

### 6. Concurrency anomaly (two sessions)

```sql
-- SESSION 1
START TRANSACTION;
SELECT Balance FROM Accounts WHERE Account_ID = 101;

-- SESSION 2
START TRANSACTION;
UPDATE Accounts SET Balance = Balance - 500 WHERE Account_ID = 101;
COMMIT;

-- SESSION 1
SELECT Balance FROM Accounts WHERE Account_ID = 101;
COMMIT;
```

## Balance After Each Step

| Step | Amit (101) | Rahul (102) |
|------|-----------:|------------:|
| Initial table | 10000.00 | 8000.00 |
| After BEGIN / COMMIT (transfer 2000) | 8000.00 | 10000.00 |
| After ROLLBACK (withdrawal undone) | 8000.00 | 10000.00 |
| After SAVEPOINT (only the 1000 deduction kept) | 7000.00 | 10000.00 |
| After partial failure (rolled back) | 7000.00 | 10000.00 |
| After isolation-level reads (no changes) | 7000.00 | 10000.00 |
| After concurrency demo (Session 2 committed −500) | 6500.00 | 10000.00 |

## Output

### 1. Initial account table

![Initial Table](outputs/01_initial_accounts_table.png)

### 2. BEGIN and COMMIT

![Begin and Commit](outputs/02_begin_commit.png)

### 3. ROLLBACK

![Rollback](outputs/03_rollback.png)

### 4. SAVEPOINT

![Savepoint](outputs/04_savepoint.png)

### 5. Partial failure

![Partial Failure](outputs/05_partial_failure.png)

### 6. Isolation levels

![Isolation Levels](outputs/06_isolation_levels.png)

### 7. Concurrency anomaly (two sessions)

![Concurrency Anomaly](outputs/07_concurrency_anomaly_two_sessions.png)

### 8. Final table

![Final Table](outputs/08_final_table.png)

## Notes

- In the partial-failure test, the `UPDATE` on account `999` runs without an error and simply affects **0 rows**. The application would have to check the affected-row count and then issue `ROLLBACK`, which is what restores Amit's balance.
- `SET TRANSACTION ISOLATION LEVEL ...` (without `SESSION`) applies only to the **next** transaction.
- MySQL's default level is `REPEATABLE READ`: Session 1 keeps seeing its original snapshot after Session 2 commits. To observe a **non-repeatable read** (the same `SELECT` returning a different value inside one transaction), run Session 1 under `READ COMMITTED`.

## Result

The `COMMIT`, `ROLLBACK` and `SAVEPOINT` operations behaved as expected on the `Accounts` table, the incomplete transfer was rolled back without changing any balance, the three isolation levels were applied, and the two-session experiment showed Session 2's committed update (Amit's balance reduced to 6500.00).
