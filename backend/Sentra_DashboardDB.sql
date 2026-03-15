/* =====================================================
   SENTRA INCIDENT MANAGEMENT SYSTEM DATABASE
   Demonstrates:
   DDL, DML, DCL, TCL
   Constraints
   Joins
   Views
   Index
   Stored Procedures
   Triggers
   Aggregation
   ===================================================== */


/* =========================
   DDL : DATABASE
   ========================= */

DROP DATABASE IF EXISTS sentra;
CREATE DATABASE sentra;
USE sentra;


/* =========================
   DDL : TABLES
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
    type VARCHAR(50),
    severity VARCHAR(20),
    description TEXT,
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    confidence INT,
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
    status VARCHAR(30),
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (incident_id) REFERENCES incidents(incident_id)
);

CREATE TABLE responses (
    response_id INT AUTO_INCREMENT PRIMARY KEY,
    incident_id INT,
    responder_id INT,
    response_time INT,
    resolved BOOLEAN,
    FOREIGN KEY (incident_id) REFERENCES incidents(incident_id),
    FOREIGN KEY (responder_id) REFERENCES responders(responder_id)
);


/* =========================
   INDEXES
   ========================= */

CREATE INDEX idx_incident_type ON incidents(type);
CREATE INDEX idx_severity ON incidents(severity);


/* =========================
   DML : INSERT DATA
   ========================= */

INSERT INTO users(name,email,role) VALUES
('Arjun','arjun@sentra.com','Reporter'),
('Meera','meera@sentra.com','Reporter'),
('Admin','admin@sentra.com','Admin');

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
   DML : UPDATE
   ========================= */

UPDATE incidents
SET severity='Critical'
WHERE incident_id=3;


/* =========================
   DML : DELETE
   ========================= */

DELETE FROM reports
WHERE report_id=2;


/* =========================
   TCL : TRANSACTION
   ========================= */

START TRANSACTION;

INSERT INTO incidents(type,severity,description)
VALUES ('Flood','High','Street flooding reported');

ROLLBACK;


/* =========================
   JOINS
   ========================= */

-- INNER JOIN
SELECT users.name,
       incidents.type,
       reports.status
FROM users
INNER JOIN reports
ON users.user_id = reports.user_id
INNER JOIN incidents
ON reports.incident_id = incidents.incident_id;

-- LEFT JOIN
SELECT users.name,
       reports.report_id
FROM users
LEFT JOIN reports
ON users.user_id = reports.user_id;

-- RIGHT JOIN
SELECT incidents.type,
       responses.response_time
FROM incidents
RIGHT JOIN responses
ON incidents.incident_id = responses.incident_id;


/* =========================
   AGGREGATION
   ========================= */

SELECT type, COUNT(*) AS total_incidents
FROM incidents
GROUP BY type;

SELECT AVG(response_time) AS avg_response_time
FROM responses;


/* =========================
   VIEW
   ========================= */

CREATE VIEW incident_summary AS
SELECT
incidents.type,
incidents.severity,
responses.response_time,
responses.resolved
FROM incidents
JOIN responses
ON incidents.incident_id = responses.incident_id;


/* =========================
   STORED PROCEDURE
   ========================= */

DELIMITER //

CREATE PROCEDURE GetHighSeverityIncidents()
BEGIN
    SELECT *
    FROM incidents
    WHERE severity='High' OR severity='Critical';
END //

DELIMITER ;

CALL GetHighSeverityIncidents();


/* =========================
   TRIGGER
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


/* =========================
   DCL : USER PERMISSIONS
   ========================= */

CREATE USER IF NOT EXISTS 'sentra_user'@'localhost'
IDENTIFIED BY 'password123';

GRANT SELECT, INSERT, UPDATE, DELETE
ON sentra.*
TO 'sentra_user'@'localhost';

REVOKE DELETE
ON sentra.*
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


/* =====================================================
   RELATIONAL ALGEBRA (Conceptual)

   σ severity='High' (incidents)

   π type,severity (incidents)

   users ⨝ reports ⨝ incidents

   ===================================================== */


/* =====================================================
   TRC (Tuple Relational Calculus)

   { t | incidents(t) ∧ t.severity = 'High' }

   ===================================================== */


/* =====================================================
   DRC (Domain Relational Calculus)

   { <type, severity> |
     ∃ id,desc,lat,long
     (incidents(id,type,severity,desc,lat,long))
   }

   ===================================================== */