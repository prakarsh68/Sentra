/* =====================================================
COMPLETE DBMS DEMO (NORMALIZATION + ACID + TRIGGERS + MORE)
===================================================== */

DROP DATABASE IF EXISTS full_demo;
CREATE DATABASE full_demo;
USE full_demo;

-------------------------------------------------------
-- 🔴 UNF (Unnormalized Form)
-------------------------------------------------------

CREATE TABLE IncidentData_UNF (
    incident_id INT,
    user_name VARCHAR(100),
    user_email VARCHAR(100),
    responders VARCHAR(200),
    departments VARCHAR(200)
);

INSERT INTO IncidentData_UNF VALUES
(1,'Arjun','arjun@sentra.com','Ravi,Kumar','Ambulance,Police'),
(2,'Meera','meera@sentra.com','Suresh','Fire Department');

SELECT * FROM IncidentData_UNF;


-------------------------------------------------------
-- 🟡 1NF (Atomic Values)
-------------------------------------------------------

CREATE TABLE IncidentData_1NF (
    incident_id INT,
    user_name VARCHAR(100),
    user_email VARCHAR(100),
    responder_name VARCHAR(100),
    department VARCHAR(100)
);

INSERT INTO IncidentData_1NF VALUES
(1,'Arjun','arjun@sentra.com','Ravi','Ambulance'),
(1,'Arjun','arjun@sentra.com','Kumar','Police'),
(2,'Meera','meera@sentra.com','Suresh','Fire Department');

SELECT * FROM IncidentData_1NF;


-------------------------------------------------------
-- 🟢 2NF (Remove Partial Dependency)
-------------------------------------------------------

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

INSERT INTO users VALUES
(1,'Arjun','arjun@sentra.com'),
(2,'Meera','meera@sentra.com');

SELECT * FROM users;


CREATE TABLE incidents (
    incident_id INT PRIMARY KEY,
    user_id INT,
    type VARCHAR(50),
    severity VARCHAR(20),
    confidence INT CHECK (confidence BETWEEN 0 AND 100)
);

INSERT INTO incidents VALUES
(1,1,'Accident','Low',60),
(2,2,'Fire','High',80);

SELECT * FROM incidents;


CREATE TABLE responders (
    responder_id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(100)
);

INSERT INTO responders VALUES
(1,'Ravi','Ambulance'),
(2,'Kumar','Police'),
(3,'Suresh','Fire Department');

SELECT * FROM responders;


CREATE TABLE responses (
    incident_id INT,
    responder_id INT,
    response_time INT,
    resolved BOOLEAN
);

INSERT INTO responses VALUES
(1,1,6,TRUE),
(1,2,8,TRUE),
(2,3,10,FALSE);

SELECT * FROM responses;


-------------------------------------------------------
-- 🔵 3NF (Remove Transitive Dependency)
-------------------------------------------------------

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100)
);

INSERT INTO departments VALUES
(1,'Ambulance'),
(2,'Police'),
(3,'Fire Department');

SELECT * FROM departments;


CREATE TABLE responders_3NF (
    responder_id INT PRIMARY KEY,
    name VARCHAR(100),
    dept_id INT
);

INSERT INTO responders_3NF VALUES
(1,'Ravi',1),
(2,'Kumar',2),
(3,'Suresh',3);

SELECT * FROM responders_3NF;


-------------------------------------------------------
-- 🔐 TRANSACTIONS (ACID)
-------------------------------------------------------

START TRANSACTION;

INSERT INTO incidents VALUES (3,1,'Flood','High',90);

-- Rollback ensures Atomicity
ROLLBACK;

-- If COMMIT used → Durability


-------------------------------------------------------
-- 🔄 CONCURRENCY (LOCKING DEMO)
-------------------------------------------------------

-- This update applies EXCLUSIVE LOCK internally
UPDATE incidents
SET severity='Critical'
WHERE incident_id=1;


-------------------------------------------------------
-- 👁️ VIEWS
-------------------------------------------------------

CREATE VIEW incident_summary AS
SELECT i.incident_id, u.name, i.type, i.severity
FROM incidents i
JOIN users u ON i.user_id = u.user_id;

SELECT * FROM incident_summary;


-------------------------------------------------------
-- ⚙️ STORED PROCEDURE
-------------------------------------------------------

DELIMITER //

CREATE PROCEDURE GetCriticalIncidents()
BEGIN
    SELECT * FROM incidents WHERE severity='Critical';
END //

DELIMITER ;

CALL GetCriticalIncidents();


-------------------------------------------------------
-- 🔢 FUNCTION
-------------------------------------------------------

DELIMITER //

CREATE FUNCTION getResolvedCount()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM responses WHERE resolved = TRUE;
    RETURN total;
END //

DELIMITER ;

SELECT getResolvedCount();


-------------------------------------------------------
-- ⚡ TRIGGERS
-------------------------------------------------------

-- LOG TABLE
CREATE TABLE incident_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    incident_id INT,
    action VARCHAR(50),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- AFTER INSERT TRIGGER
DELIMITER //

CREATE TRIGGER after_incident_insert
AFTER INSERT ON incidents
FOR EACH ROW
BEGIN
    INSERT INTO incident_log(incident_id, action)
    VALUES (NEW.incident_id, 'Incident Created');
END //

DELIMITER ;


-- BEFORE INSERT TRIGGER (Consistency)
DELIMITER //

CREATE TRIGGER before_incident_insert
BEFORE INSERT ON incidents
FOR EACH ROW
BEGIN
    IF NEW.confidence > 100 THEN
        SET NEW.confidence = 100;
    END IF;
END //

DELIMITER ;


-------------------------------------------------------
-- 🔑 DCL (ACCESS CONTROL)
-------------------------------------------------------

CREATE USER IF NOT EXISTS 'demo_user'@'localhost'
IDENTIFIED BY 'password123';

GRANT SELECT, INSERT, UPDATE ON full_demo.* TO 'demo_user'@'localhost';

REVOKE DELETE ON full_demo.* FROM 'demo_user'@'localhost';


-------------------------------------------------------
-- 📊 FINAL SELECTS (IMPORTANT FOR EXAM)
-------------------------------------------------------

-- UNF
SELECT * FROM IncidentData_UNF;

-- 1NF
SELECT * FROM IncidentData_1NF;

-- 2NF
SELECT * FROM users;
SELECT * FROM incidents;
SELECT * FROM responders;
SELECT * FROM responses;

-- 3NF
SELECT * FROM departments;
SELECT * FROM responders_3NF;

-- Logs
SELECT * FROM incident_log;

-- View
SELECT * FROM incident_summary;