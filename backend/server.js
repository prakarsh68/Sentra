require("dotenv").config();

const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");

const app = express();

/* =====================
   MIDDLEWARE
===================== */
app.use(cors());
app.use(express.json());

/* =====================
   DB CONNECTION
===================== */
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

db.connect((err) => {
  if (err) {
    console.error("DB Connection Error:", err);
  } else {
    console.log("MySQL Connected");
  }
});

/* =====================
   HEALTH CHECK
===================== */
app.get("/", (req, res) => {
  res.send("API Running...");
});

/* =====================
   INSERT INCIDENT
===================== */
app.post("/report", (req, res) => {
  const { user_id, type, severity, confidence } = req.body;

  if (!type || !severity) {
    return res.status(400).send("Missing required fields");
  }

  const sql = `
    INSERT INTO incidents (user_id, type, severity, confidence)
    VALUES (?, ?, ?, ?)
  `;

  db.query(sql, [user_id || 1, type, severity, confidence || 40], (err) => {
    if (err) {
      console.error("Insert Error:", err);
      return res.status(500).send("Database insert failed");
    }

    res.json({ message: "Incident saved to SQL" });
  });
});

/* =====================
   GET INCIDENTS
===================== */
app.get("/incidents", (req, res) => {
  db.query("SELECT * FROM incidents ORDER BY incident_id DESC", (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).send("Fetch error");
    }
    res.json(result);
  });
});

/* =====================
   ANALYTICS
===================== */
app.get("/analytics", (req, res) => {
  const sql = `
    SELECT 
      type,
      COUNT(*) AS total,
      AVG(confidence) AS avg_confidence
    FROM incidents
    GROUP BY type
  `;

  db.query(sql, (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).send("Analytics error");
    }
    res.json(result);
  });
});

/* =====================
   SERVER START
===================== */
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});