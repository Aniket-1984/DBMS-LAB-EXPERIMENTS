# Experiment 2 — Relational Schema & MySQL Implementation: Indian E-Commerce Platform

**Name:** ANIKET &nbsp;|&nbsp; **Roll No:** 25LBCS3174

## Aim

To convert the ER diagram of the Indian e-commerce platform into a **relational schema** and implement it in **MySQL** using primary keys, foreign keys, `NOT NULL`, `UNIQUE`, `ON DELETE CASCADE`, and `ON DELETE SET NULL` constraints, followed by sample data insertion and referential-integrity testing.

## Relational Schema

Customer, Address, Seller, Category, Product, Orders, OrderItem, Payment, and Delivery.

| Table | Key constraints |
|-------|-----------------|
| **Customer** | `Customer_ID` PK; `Email` NOT NULL + UNIQUE; `Mobile_No` UNIQUE |
| **Address** | FK `Customer_ID` → Customer **ON DELETE CASCADE** |
| **Seller** | `Email` UNIQUE; `GSTIN` UNIQUE |
| **Category** | `Category_Name` NOT NULL + UNIQUE |
| **Product** | `Price` NOT NULL; FK `Category_ID` → Category **ON DELETE SET NULL** |
| **Orders** | `Order_Date` NOT NULL; FK `Customer_ID` → Customer **ON DELETE CASCADE** |
| **OrderItem** | Composite PK (`Order_ID`, `Product_ID`); both FKs **ON DELETE CASCADE** |
| **Payment** | `Order_ID` NOT NULL + UNIQUE (1:1 with Orders); FK **ON DELETE CASCADE** |
| **Delivery** | `Order_ID` NOT NULL + UNIQUE (1:1 with Orders); `Tracking_Number` UNIQUE; FK **ON DELETE CASCADE** |

## Sample Data

The script inserts 3 customers, 2 addresses, 2 sellers, 2 categories, 2 products, 2 orders, 2 order items, 2 payments, and 2 deliveries, then selects from every table.

## Referential-Integrity Tests

```sql
-- Expected to FAIL: Customer_ID 999 does not exist
-- INSERT INTO Orders VALUES (503, 999, '2026-09-10', 'Placed', 5000.00);

-- ON DELETE SET NULL test (run separately): deletes Category 301,
-- sets related Product.Category_ID to NULL
-- DELETE FROM Category WHERE Category_ID = 301;

-- ON DELETE CASCADE test (run separately): deletes Customer 101 and
-- cascades to the customer's dependent Address and Orders records
-- DELETE FROM Customer WHERE Customer_ID = 101;
```

**Expected results:** the commented `INSERT` using `Customer_ID 999` fails because that customer does not exist. The `ON DELETE SET NULL` test sets the related `Product.Category_ID` to NULL. The `ON DELETE CASCADE` test deletes the customer's dependent Address and Orders records.

## Full Report

The complete lab record including the full source code is available in [`Experiment_2_Relational_Schema_MySQL.pdf`](Experiment_2_Relational_Schema_MySQL.pdf).

## Result

The ER diagram was converted into relational tables and implemented with primary keys, foreign keys, uniqueness and nullability constraints, and referential actions.
