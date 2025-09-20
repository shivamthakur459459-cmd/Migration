-- ==================================================
-- Task 7: Data Migration Between Two Databases
-- ==================================================

-- Step 0: Create a new database
DROP DATABASE IF EXISTS migration_demo;
CREATE DATABASE migration_demo;
USE migration_demo;

-- ==================================================
-- 1. Legacy Schema (Denormalized Table)
-- ==================================================
DROP TABLE IF EXISTS legacy_students;

CREATE TABLE legacy_students (
    id INT PRIMARY KEY,
    student_name VARCHAR(100),
    class VARCHAR(20),
    subject1 VARCHAR(50),
    subject1_marks INT,
    subject2 VARCHAR(50),
    subject2_marks INT
);

-- Insert sample legacy data
INSERT INTO legacy_students VALUES
(1, 'Alice', '10A', 'Math', 85, 'Science', 90),
(2, 'Bob', '10B', 'Math', 78, 'English', 88),
(3, 'Charlie', '10A', 'Science', 92, 'English', 81);

-- ==================================================
-- 2. New Normalized Schema
-- ==================================================
DROP TABLE IF EXISTS marks;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    class VARCHAR(20)
);

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY AUTO_INCREMENT,
    subject_name VARCHAR(50) UNIQUE
);

CREATE TABLE marks (
    mark_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    subject_id INT,
    marks INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- ==================================================
-- 3. Migration Script
-- ==================================================

-- Step 1: Insert students
INSERT INTO students (student_id, name, class)
SELECT id, student_name, class
FROM legacy_students;

-- Step 2: Insert unique subjects
INSERT INTO subjects (subject_name)
SELECT DISTINCT subject1 FROM legacy_students
UNION
SELECT DISTINCT subject2 FROM legacy_students;

-- Step 3: Insert marks for subject1
INSERT INTO marks (student_id, subject_id, marks)
SELECT l.id, s.subject_id, l.subject1_marks
FROM legacy_students l
JOIN subjects s ON l.subject1 = s.subject_name;

-- Step 4: Insert marks for subject2
INSERT INTO marks (student_id, subject_id, marks)
SELECT l.id, s.subject_id, l.subject2_marks
FROM legacy_students l
JOIN subjects s ON l.subject2 = s.subject_name;

-- ==================================================
-- 4. Verification Queries
-- ==================================================

-- Students Table
SELECT * FROM students;

-- Subjects Table
SELECT * FROM subjects;

-- Marks Table (with join for readability)
SELECT st.name, st.class, sb.subject_name, m.marks
FROM marks m
JOIN students st ON m.student_id = st.student_id
JOIN subjects sb ON m.subject_id = sb.subject_id
ORDER BY st.student_id, sb.subject_name;