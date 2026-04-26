# 🚨 Sentra - Intelligent Emergency Response & Crisis Management System

**Sentra** is a real-time command and control dashboard designed to streamline emergency response operations. Integrated with live geospatial tracking, automated priority scoring, and crowd-sourced verification, Sentra empowers first responders and civic authorities to make faster, data-driven decisions during critical incidents.

---

## 🚀 Why Sentra?

Traditional emergency systems suffer from:

* ❌ Information overload
* ❌ False or duplicate reports
* ❌ Delayed response times
* ❌ Lack of coordination

### ✅ Sentra solves this by:

* ⚡ Prioritizing critical incidents instantly
* 🧠 Converting raw data into actionable insights
* 🌍 Providing a unified real-time dashboard
* 🤝 Bridging citizens and responders

---

## 💡 Unique Selling Proposition (USP)

> **“From chaos to clarity in real-time emergency response.”**

* 🧠 **Priority Intelligence Engine** → Auto-scores incidents (0–100)
* 🔄 **Hybrid Verification** → Crowd + IoT validation
* 📍 **Live Situational Awareness** → Real-time maps with clustering
* 🧹 **Smart Deduplication** → Eliminates duplicate reports
* 🔗 **Hybrid Architecture** → Firebase (real-time) + SQL (analytics)

---

## 🎯 Target Audience (Clustered)

### 🚨 Response & Enforcement

* Ambulance services
* Fire departments
* Police & traffic units

👉 Real-time response & prioritization

---

### 🏙️ Government & Administration

* Smart cities
* Municipal authorities
* Disaster management agencies

👉 City-wide monitoring & coordination

---

### 🏥 Healthcare & Crisis Units

* Hospitals
* Emergency medical centers

👉 Faster patient response

---

### 🌍 Disaster & Relief Organizations

* NGOs
* Rescue teams

👉 Large-scale crisis coordination

---

### 👥 Citizens

* General public reporting incidents

👉 First layer of real-time data

---

## 🚀 Key Features

### 📍 Real-Time Geospatial Tracking

Interactive maps powered by **Leaflet** visualize incidents as they happen, using heatmaps and clustering to identify high-risk zones immediately.

---

### ⚡ Automated Priority Intelligence

A custom algorithm (`utils/priority.ts`) analyzes severity, time, and verification status to auto-calculate a **Priority Score (0–100)**, ensuring critical incidents are handled first.

---

### 👥 Crowd & IoT Verification

Reduces false alarms through a hybrid verification system:

* **Crowd-Sourcing:** Aggregates user reports
* **Sensor Simulation:** Mimics IoT-based validation

---

### 🔍 Smart Deduplication

Intelligent logic (`utils/deduplication.ts`) detects duplicate reports within the same geolocation and time window to prevent data clutter.

---

### 📊 Analytics (SQL Integration)

* Incident trends
* Type-based aggregation
* Confidence metrics

---

### 📱 Cross-Platform Support

Built with **Capacitor**, Sentra runs seamlessly as:

* 🌐 Web dashboard
* 📱 Android application

---

## 🛠️ Tech Stack

### 🎨 Frontend

* React (Vite)
* TypeScript

### 🎭 Styling

* Tailwind CSS
* PostCSS

### 🔥 Backend & Data

* Firebase Firestore (real-time NoSQL)
* MySQL (analytics)
* Node.js + Express (API)

### 🗺️ Maps & GIS

* Leaflet
* React Leaflet

### 📱 Mobile

* Capacitor (Android)

### 🎨 UI & Icons

* Lucide React

---

## 📦 Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/sentra.git
cd sentra
```

---

### 2. Install Dependencies

```bash
npm install
```

---

### 3. Environment Configuration

Create a `.env` file in the root directory:

```env
VITE_FIREBASE_API_KEY=your_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_storage_bucket
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
```

---

### 4. Run Development Server

```bash
npm run dev
```

👉 App runs at: **http://localhost:5173**

---

## 📱 Mobile Build (Android)

```bash
npm run build
npx cap sync
npx cap open android
```

---

## 🗄️ SQL Setup

```sql
CREATE DATABASE sentra;
USE sentra;

CREATE TABLE incidents (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  type VARCHAR(50),
  severity VARCHAR(20),
  confidence INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 📂 Project Structure

```text
src/
├── components/       # UI components
├── context/          # Auth & global state
├── pages/            # Views (Dashboard, Map, Login)
├── services/         # Firebase & API logic
│   ├── firebase.ts
│   └── incidents.service.ts
├── utils/
│   ├── deduplication.ts
│   └── priority.ts
├── App.tsx
└── main.tsx
```

---

## 🤝 Contributing

Contributions are welcome!

```bash
git checkout -b feature/AmazingFeature
git commit -m "Add feature"
git push origin feature/AmazingFeature
```

---

## 📄 License

MIT License

---

## 👨‍💻 Author

Built with ❤️ for real-world impact.
