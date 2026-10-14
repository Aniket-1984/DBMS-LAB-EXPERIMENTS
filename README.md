# DBMS Lab Experiments

DBMS Lab experiments — **Aniket (25LBCS3174)**, Semester 3.

Each experiment folder contains the complete SQL code base, output screenshots, and a detailed README (aim, description, schema, source code, outputs, and result). Experiments 1 and 2 are provided as the original lab-record PDFs.

## Experiment Index

| # | Experiment | Folder | Topics Covered |
|---|-----------|--------|----------------|
| 1 | [ER Diagram — Indian E-Commerce Platform](Experiment-1_ER-Diagram/) | `Experiment-1_ER-Diagram` | ER modelling, keys, weak entity, multivalued attribute, ISA/specialization, cardinalities |
| 2 | [Relational Schema & MySQL Implementation](Experiment-2_Relational-Schema-MySQL/) | `Experiment-2_Relational-Schema-MySQL` | ER → relational conversion, PK/FK, UNIQUE, NOT NULL, ON DELETE CASCADE / SET NULL, referential integrity |
| 3 | [SQL Queries on Employee–Department–Project DB](Experiment-3_SQL-Queries/) | `Experiment-3_SQL-Queries` | Selection, projection, aggregation, GROUP BY, HAVING, CASE, ORDER BY |
| 4 | [Joins, Subqueries & EXPLAIN](Experiment-4_Joins_Subqueries/) | `Experiment-4_Joins_Subqueries` | INNER/LEFT/self/3-way joins, correlated subquery, EXISTS, simulated INTERSECT/EXCEPT, EXPLAIN |
| 5 | [Views & Recursive CTE](Experiment-5_Views_Recursive_CTE/) | `Experiment-5_Views_Recursive_CTE` | CREATE VIEW, updatable views, WITH RECURSIVE reporting chains (MySQL 8.0+) |
| 6 | [Stored Procedures & Triggers](Experiment-6_Stored-Procedures_Triggers/) | `Experiment-6_Stored-Procedures_Triggers` | transfer_employee procedure, SIGNAL/handlers, transactions, salary validation & audit triggers |

## Requirements

- **MySQL 8.0 or later** (Experiments 5 and 6 require `WITH RECURSIVE` and `SIGNAL` support)
- Execute the `.sql` files in order; output screenshots for every query are in each experiment's `outputs/` folder
