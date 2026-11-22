# Experiment 9 — Indexing and Query Performance: Railway Booking

**Name:** ANIKET &nbsp;|&nbsp; **Roll No:** 25LBCS3174

## Aim

To create a **Railway Booking** table with at least 5,000 records, benchmark query performance before and after creating **single-column** and **composite indexes**, and compare the execution plans using `EXPLAIN`.

## Description

An **index** is a data structure that lets the database find rows without scanning the whole table. Without an index, a query such as `WHERE Train_No = 12005` must read every row (`type = ALL`, a full table scan). With an index on `Train_No`, MySQL jumps directly to the matching rows (`type = ref`).

A **composite index** covers several columns. The index `(Train_No, Journey_Date)` can serve queries that filter on both columns — and also on `Train_No` alone, because `Train_No` is its leftmost column — and narrows the search much further than a single-column index.

In this experiment a stored procedure generates **5,000 bookings** across **20 trains** (`12000` to `12019`) and 365 journey dates. The same queries are explained before indexing, after the single-column index `idx_train`, and after the composite index `idx_train_date`.

> The following SQL uses **MySQL 8.0 or later**.

## Files

| File | Description |
|------|-------------|
| [`exp9_indexing_railway_booking.sql`](exp9_indexing_railway_booking.sql) | Complete SQL code base (table + data generator + indexes + EXPLAIN queries) |
| [`ANIKET09.pdf`](ANIKET09.pdf) | Original lab record PDF |
| [`outputs/`](outputs/) | Output screenshots |

## Schema

- **Railway_Booking** (`Booking_ID` PK, `Passenger_Name`, `Train_No`, `Source`, `Destination`, `Journey_Date`, `Seat_No`, `Fare`)

Indexes created: `idx_train (Train_No)` and `idx_train_date (Train_No, Journey_Date)`.

## Source Code

The full code is in [`exp9_indexing_railway_booking.sql`](exp9_indexing_railway_booking.sql). It creates the table, inserts 5,000 rows, compares `EXPLAIN` plans before and after indexing, and runs the indexed queries.

## EXPLAIN Comparison

| Stage | type | key | key_len | ref | rows examined | filtered | Extra |
|-------|------|-----|--------:|-----|--------------:|---------:|-------|
| Before indexing | `ALL` | NULL | NULL | NULL | 4961 | 10 | Using where |
| Single-column index | `ref` | `idx_train` | 5 | const | 250 | 100 | — |
| Composite index | `ref` | `idx_train_date` | 9 | const, const | 1 | 100 | — |

- **Before indexing:** a full table scan reads about all 5,000 rows to find one train's bookings.
- **Single-column index:** only the 250 rows of the train (5000 ÷ 20 trains) are read.
- **Composite index:** the optimizer picks `idx_train_date` over `idx_train` and uses both columns (`const, const`), shrinking the estimate to 1 row.

## Notes

- The comparison above is based on the `EXPLAIN` plans. To also measure real execution time, run the optional `EXPLAIN ANALYZE` statements included in the `.sql` file on MySQL 8.0.18 or later.
- Indexes speed up reads but add storage and slow down `INSERT`/`UPDATE`/`DELETE`, so they should be created for columns that are frequently searched.

## Result

A Railway Booking table with 5,000 records was created. Without an index, the query performed a full table scan; the single-column index reduced the examined rows from 4961 to 250, and the composite index on `(Train_No, Journey_Date)` reduced it further to 1, demonstrating the benefit of indexing as shown by `EXPLAIN`.
