# Experiment 7 — Normalization: UNF to 1NF, 2NF, 3NF and BCNF

**Name:** ANIKET &nbsp;|&nbsp; **Roll No:** 25LBCS3174

## Aim

To take a denormalized registration table, identify its functional dependencies, normalize it step-by-step from UNF to 1NF, 2NF, 3NF and BCNF, and verify lossless join and dependency preservation using SQL queries.

## Description

The starting table `Registration_UNF` stores student, course, instructor and registration data together. Normalization removes repeated and transitively dependent data through decomposition:

- **1NF** — all attributes contain atomic values (`Registration_1NF`).
- **2NF** — remove partial dependencies by creating `Students`, `Courses` and `Registrations`.
- **3NF** — remove the transitive dependency `course_id -> instructor_id -> instructor_name, department` by creating `Instructors` and `Courses_3NF`.
- **BCNF** — every determinant in the final tables is a primary key.

The join of `Registrations`, `Students`, `Courses_3NF` and `Instructors` reproduces the original registration rows, and the dependency checks return no violations.

## Functional Dependencies

| FD | Meaning |
|----|---------|
| `registration_id -> student_id, course_id, semester, grade` | A registration identifies its student, course, semester and grade |
| `student_id -> student_name` | A student ID determines one student name |
| `course_id -> course_name, instructor_id` | A course determines its name and instructor |
| `instructor_id -> instructor_name, department` | An instructor determines their name and department |

The transitive dependency `course_id -> instructor_id -> instructor_name, department` is removed in 3NF.

## Files

| File | Description |
|------|-------------|
| [`exp7_normalization.sql`](exp7_normalization.sql) | Complete rerunnable MySQL code base |

## Schema

**Original UNF:**

`Registration_UNF(registration_id, student_id, student_name, course_id, course_name, instructor_id, instructor_name, department, semester, grade)`

**Normalized 3NF/BCNF:**

- `Students(student_id PK, student_name)`
- `Instructors(instructor_id PK, instructor_name, department)`
- `Courses_3NF(course_id PK, course_name, instructor_id FK -> Instructors)`
- `Registrations(registration_id PK, student_id FK -> Students, course_id FK -> Courses_3NF, semester, grade)`

## Key SQL

### 1NF

```sql
CREATE TABLE Registration_1NF AS
SELECT * FROM Registration_UNF;
```

### 2NF

```sql
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);
```

### 3NF / BCNF

```sql
CREATE TABLE Instructors (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(100) NOT NULL,
    department VARCHAR(100)
);

CREATE TABLE Courses_3NF (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    instructor_id INT,
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
);
```

### Lossless join

```sql
SELECT r.registration_id, s.student_id, s.student_name,
       c.course_id, c.course_name,
       i.instructor_id, i.instructor_name, i.department,
       r.semester, r.grade
FROM Registrations r
JOIN Students s ON r.student_id = s.student_id
JOIN Courses_3NF c ON r.course_id = c.course_id
JOIN Instructors i ON c.instructor_id = i.instructor_id
ORDER BY r.registration_id;
```

### Dependency-preservation checks

Each query below should return no rows:

```sql
-- student_id -> student_name
SELECT student_id FROM Students
GROUP BY student_id
HAVING COUNT(DISTINCT student_name) > 1;

-- instructor_id -> instructor_name, department
SELECT instructor_id FROM Instructors
GROUP BY instructor_id
HAVING COUNT(DISTINCT instructor_name) > 1
    OR COUNT(DISTINCT department) > 1;

-- course_id -> course_name, instructor_id
SELECT course_id FROM Courses_3NF
GROUP BY course_id
HAVING COUNT(DISTINCT course_name) > 1
    OR COUNT(DISTINCT instructor_id) > 1;
```

## Result

The registration relation was normalized from UNF through 1NF and 2NF to 3NF/BCNF. The four-table join reconstructs the original rows, and the dependency-preservation queries find no violations.
