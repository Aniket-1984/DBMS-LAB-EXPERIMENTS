-- ============================================================
-- Experiment 7 : Normalization — UNF to 1NF, 2NF, 3NF and BCNF
-- Lossless join and dependency-preservation verification
-- Requires MySQL 8.0 or later
-- ============================================================

DROP TABLE IF EXISTS Registrations;
DROP TABLE IF EXISTS Courses_3NF;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Instructors;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Registration_1NF;
DROP TABLE IF EXISTS Registration_UNF;

-- STEP 1: DENORMALIZED TABLE (UNF)
CREATE TABLE Registration_UNF (
    registration_id INT,
    student_id INT,
    student_name VARCHAR(100),
    course_id INT,
    course_name VARCHAR(100),
    instructor_id INT,
    instructor_name VARCHAR(100),
    department VARCHAR(100),
    semester VARCHAR(20),
    grade CHAR(2)
);

INSERT INTO Registration_UNF VALUES
(501, 101, 'Ankan Bhattacharjee', 201, 'Database Systems', 301, 'Dr Mehta', 'CSE', 'Semester 3', 'A'),
(502, 102, 'Unnati Mishra', 202, 'Operating Systems', 302, 'Dr Rao', 'CSE', 'Semester 3', 'B'),
(503, 103, 'Riya Patel', 203, 'Computer Networks', 303, 'Dr Sen', 'IT', 'Semester 4', 'A'),
(504, 104, 'Isha Gupta', 201, 'Database Systems', 301, 'Dr Mehta', 'CSE', 'Semester 3', 'B'),
(505, 105, 'Arjun Das', 204, 'Artificial Intelligence', 304, 'Dr Nair', 'AIML', 'Semester 5', 'A');

SELECT * FROM Registration_UNF;

-- STEP 2: 1NF
CREATE TABLE Registration_1NF AS
SELECT * FROM Registration_UNF;

SELECT * FROM Registration_1NF;

-- STEP 3: 2NF
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);

INSERT INTO Students
SELECT DISTINCT student_id, student_name
FROM Registration_UNF;

CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    instructor_id INT,
    instructor_name VARCHAR(100),
    department VARCHAR(100)
);

INSERT INTO Courses
SELECT DISTINCT
    course_id,
    course_name,
    instructor_id,
    instructor_name,
    department
FROM Registration_UNF;

CREATE TABLE Registrations (
    registration_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    semester VARCHAR(20),
    grade CHAR(2),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

INSERT INTO Registrations
SELECT DISTINCT
    registration_id,
    student_id,
    course_id,
    semester,
    grade
FROM Registration_UNF;

-- STEP 4: 3NF / BCNF
CREATE TABLE Instructors (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(100) NOT NULL,
    department VARCHAR(100)
);

INSERT INTO Instructors
SELECT DISTINCT
    instructor_id,
    instructor_name,
    department
FROM Registration_UNF;

CREATE TABLE Courses_3NF (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    instructor_id INT,
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
);

INSERT INTO Courses_3NF
SELECT DISTINCT
    course_id,
    course_name,
    instructor_id
FROM Registration_UNF;

-- Recreate Registrations so its course foreign key points to the 3NF table.
DROP TABLE Registrations;

CREATE TABLE Registrations (
    registration_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    semester VARCHAR(20),
    grade CHAR(2),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses_3NF(course_id)
);

INSERT INTO Registrations
SELECT DISTINCT
    registration_id,
    student_id,
    course_id,
    semester,
    grade
FROM Registration_UNF;

DROP TABLE Courses;

SELECT * FROM Students;
SELECT * FROM Instructors;
SELECT * FROM Courses_3NF;
SELECT * FROM Registrations;

-- STEP 5: LOSSLESS-JOIN VERIFICATION
SELECT
    r.registration_id,
    s.student_id,
    s.student_name,
    c.course_id,
    c.course_name,
    i.instructor_id,
    i.instructor_name,
    i.department,
    r.semester,
    r.grade
FROM Registrations r
JOIN Students s ON r.student_id = s.student_id
JOIN Courses_3NF c ON r.course_id = c.course_id
JOIN Instructors i ON c.instructor_id = i.instructor_id
ORDER BY r.registration_id;

-- STEP 6: DEPENDENCY-PRESERVATION VERIFICATION
-- Every query below must return no rows.

-- student_id -> student_name
SELECT student_id
FROM Students
GROUP BY student_id
HAVING COUNT(DISTINCT student_name) > 1;

-- instructor_id -> instructor_name, department
SELECT instructor_id
FROM Instructors
GROUP BY instructor_id
HAVING COUNT(DISTINCT instructor_name) > 1
    OR COUNT(DISTINCT department) > 1;

-- course_id -> course_name, instructor_id
SELECT course_id
FROM Courses_3NF
GROUP BY course_id
HAVING COUNT(DISTINCT course_name) > 1
    OR COUNT(DISTINCT instructor_id) > 1;

-- registration_id uniqueness
SELECT registration_id
FROM Registrations
GROUP BY registration_id
HAVING COUNT(*) > 1;

-- STEP 7: FINAL RESULT TABLE
SELECT
    r.registration_id,
    s.student_name,
    c.course_name,
    i.instructor_name,
    i.department,
    r.semester,
    r.grade
FROM Registrations r
JOIN Students s ON r.student_id = s.student_id
JOIN Courses_3NF c ON r.course_id = c.course_id
JOIN Instructors i ON c.instructor_id = i.instructor_id
ORDER BY r.registration_id;
