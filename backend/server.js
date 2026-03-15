const express = require("express")
const mysql = require("mysql2")
const cors = require("cors")

const app = express()

app.use(cors())
app.use(express.json())

const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "Parkhu@1234",
  database: "sentra"
})

db.connect(err => {
  if(err){
    console.log(err)
  } else {
    console.log("MySQL Connected")
  }
})

app.get("/incidents", (req,res)=>{
  db.query("SELECT * FROM incidents",(err,result)=>{
    if(err){
      res.send(err)
    } else {
      res.json(result)
    }
  })
})

app.get("/analytics",(req,res)=>{
  db.query(
    "SELECT type, COUNT(*) as total FROM incidents GROUP BY type",
    (err,result)=>{
      if(err) res.send(err)
      else res.json(result)
    }
  )
})

app.listen(5000,()=>{
  console.log("Server running on port 5000")
})