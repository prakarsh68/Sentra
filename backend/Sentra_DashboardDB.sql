/* =====================================================
SENTRA INCIDENT MANAGEMENT SYSTEM DATABASE (FINAL)
Covers ALL RUBRIC POINTS
===================================================== */

DROP DATABASE IF EXISTS sentra;
CREATE DATABASE sentra;
USE sentra;

/* =========================
TABLES WITH STRONG CONSTRAINTS
========================= */

CREATE TABLE users (
user_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE,
role VARCHAR(50),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE incidents (
incident_id INT AUTO_INCREMENT PRIMARY KEY,
type VARCHAR(50) NOT NULL,
severity ENUM('Low','Medium','High','Critical') NOT NULL,
description TEXT,
latitude DECIMAL(10,6),
longitude DECIMAL(10,6),
confidence INT CHECK (confidence BETWEEN 0 AND 100),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE responders (
responder_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100),
department VARCHAR(50)
);

CREATE TABLE reports (
report_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT,
incident_id INT,
status VARCHAR(30) NOT NULL,
reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
FOREIGN KEY (incident_id) REFERENCES incidents(incident_id) ON DELETE CASCADE
);

CREATE TABLE responses (
response_id INT AUTO_INCREMENT PRIMARY KEY,
incident_id INT,
responder_id INT,
response_time INT,
resolved BOOLEAN,
FOREIGN KEY (incident_id) REFERENCES incidents(incident_id) ON DELETE CASCADE,
FOREIGN KEY (responder_id) REFERENCES responders(responder_id) ON DELETE CASCADE
);

/* =========================
INDEXES
========================= */

CREATE INDEX idx_incident_type ON incidents(type);
CREATE INDEX idx_severity ON incidents(severity);

/* =========================
DATA INSERTION
========================= */

INSERT INTO users(name,email,role) VALUES
('Arjun','[arjun@sentra.com](mailto:arjun@sentra.com)','Reporter'),
('Meera','[meera@sentra.com](mailto:meera@sentra.com)','Reporter'),
('Admin','[admin@sentra.com](mailto:admin@sentra.com)','Admin');

INSERT INTO incidents(type,severity,description,latitude,longitude,confidence) VALUES
('Accident','Low','Bike crash on highway',12.822300,80.042800,60),
('Medical','High','Heart attack emergency',12.825500,80.041200,90),
('Fire','High','Apartment fire reported',12.826000,80.043000,80);

INSERT INTO responders(name,department) VALUES
('Ravi','Ambulance'),
('Kumar','Police'),
('Suresh','Fire Department');

INSERT INTO reports(user_id,incident_id,status) VALUES
(1,1,'Verified'),
(2,2,'Pending'),
(1,3,'Verified');

INSERT INTO responses(incident_id,responder_id,response_time,resolved) VALUES
(1,1,6,TRUE),
(2,2,10,FALSE),
(3,3,8,TRUE);

/* =========================
UPDATE + DELETE
========================= */

UPDATE incidents SET severity='Critical' WHERE incident_id=3;
DELETE FROM reports WHERE report_id=2;

/* =========================
TRANSACTION (TCL)
========================= */

START TRANSACTION;
INSERT INTO incidents(type,severity,description)
VALUES ('Flood','High','Street flooding reported');
ROLLBACK;

/* =========================
JOINS
========================= */

SELECT u.name, i.type, r.status
FROM users u
JOIN reports r ON u.user_id = r.user_id
JOIN incidents i ON r.incident_id = i.incident_id;

SELECT u.name, r.report_id
FROM users u
LEFT JOIN reports r ON u.user_id = r.user_id;

SELECT i.type, res.response_time
FROM incidents i
RIGHT JOIN responses res ON i.incident_id = res.incident_id;

/* =========================
AGGREGATION + HAVING
========================= */

SELECT type, COUNT(*) AS total_incidents
FROM incidents
GROUP BY type
HAVING COUNT(*) >= 1;

SELECT AVG(response_time) AS avg_response_time
FROM responses;

/* =========================
SET OPERATIONS
========================= */

SELECT name FROM users
UNION
SELECT name FROM responders;

SELECT name FROM users
WHERE name IN (SELECT name FROM responders);

/* =========================
SUBQUERIES
========================= */

SELECT name
FROM users
WHERE user_id IN (
SELECT user_id FROM reports WHERE status='Verified'
);

SELECT i.type, i.severity
FROM incidents i
WHERE confidence > (
SELECT AVG(confidence)
FROM incidents
WHERE type = i.type
);

/* =========================
VIEWS
========================= */

CREATE VIEW incident_summary AS
SELECT i.type, i.severity, res.response_time, res.resolved
FROM incidents i
JOIN responses res ON i.incident_id = res.incident_id;

CREATE VIEW detailed_incident_view AS
SELECT
u.name AS reporter,
i.type,
i.severity,
r.status,
res.response_time,
res.resolved
FROM users u
JOIN reports r ON u.user_id = r.user_id
JOIN incidents i ON r.incident_id = i.incident_id
LEFT JOIN responses res ON i.incident_id = res.incident_id;

/* =========================
STORED PROCEDURE
========================= */

DELIMITER //

CREATE PROCEDURE GetHighSeverityIncidents()
BEGIN
SELECT * FROM incidents
WHERE severity='High' OR severity='Critical';
END //

DELIMITER ;

CALL GetHighSeverityIncidents();

/* =========================
FUNCTION
========================= */

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

/* =========================
TRIGGERS
========================= */

CREATE TABLE incident_log (
log_id INT AUTO_INCREMENT PRIMARY KEY,
incident_id INT,
action VARCHAR(50),
action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER after_incident_insert
AFTER INSERT ON incidents
FOR EACH ROW
BEGIN
INSERT INTO incident_log(incident_id,action)
VALUES(NEW.incident_id,'Incident Created');
END //

DELIMITER ;

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

/* =========================
CURSOR + EXCEPTION HANDLING
========================= */

DELIMITER //

CREATE PROCEDURE ProcessIncidents()
BEGIN
DECLARE done INT DEFAULT FALSE;
DECLARE inc_id INT;

```
DECLARE cur CURSOR FOR SELECT incident_id FROM incidents;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SELECT 'Error occurred';

OPEN cur;

read_loop: LOOP
    FETCH cur INTO inc_id;
    IF done THEN LEAVE read_loop; END IF;

    UPDATE incidents
    SET confidence = confidence + 1
    WHERE incident_id = inc_id;
END LOOP;

CLOSE cur;
```

END //

DELIMITER ;

CALL ProcessIncidents();

/* =========================
DCL
========================= */

CREATE USER IF NOT EXISTS 'sentra_user'@'localhost'
IDENTIFIED BY 'password123';

GRANT SELECT, INSERT, UPDATE ON sentra.*
TO 'sentra_user'@'localhost';

REVOKE DELETE ON sentra.*
FROM 'sentra_user'@'localhost';

/* =========================
TEST QUERIES
========================= */

SELECT * FROM users;
SELECT * FROM incidents;
SELECT * FROM reports;
SELECT * FROM responders;
SELECT * FROM responses;
SELECT * FROM incident_log;
SELECT * FROM incident_summary;
SELECT * FROM detailed_incident_view;
