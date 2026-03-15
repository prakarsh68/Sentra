# Sentra - Intelligent Emergency Response & Crisis Management System

**Sentra** is a real-time command and control dashboard designed to streamline emergency response operations. Integrated with live geospatial tracking, automated priority scoring, and crowd-sourced verification, Sentra empowers first responders and civic authorities to make faster, data-driven decisions during critical incidents.

## 🚀 Key Features

*   **📍 Real-Time Geospatial Tracking**
    Interactive maps powered by **Leaflet** visualize incidents as they happen, using heatmaps and clustering to identify high-risk zones immediately.

*   **⚡ Automated Priority Intelligence**
    A custom algorithm ([utils/priority.ts](cci:7://file:///c:/Users/yagye/OneDrive/Desktop/Hackathon/sentra/Sentra/src/utils/priority.ts:0:0-0:0)) analyzes severity, time, and verification status to auto-calculate a "Priority Score" (0-100), ensuring critical life-threatening events float to the top.

*   **👥 Crowd & IoT Verification**
    Reduces false alarms through a hybrid verification system:
    *   **Crowd-Sourcing:** Aggregates user reports to validate incident authenticity.
    *   **Sensor Integration:** Simulates integration with IoT sensors (e.g., IR sensors for fire/smog) for automated hardware verification.

*   **🔍 Smart Deduplication**
    Intelligent logic (`utils/deduplication.ts`) detects and flags duplicate reports within the same geolocation and time window to prevent data clutter.

*   **📱 Cross-Platform Support**
    Built with **Capacitor**, Sentra is designed to run seamlessly as a web dashboard and a native Android application.

## 🛠️ Tech Stack

*   **Frontend:** React (Vite), TypeScript
*   **Styling:** Tailwind CSS, PostCSS
*   **Backend & Database:** Firebase Firestore (Real-time NoSQL)
*   **Maps & GIS:** Leaflet, React Leaflet, Leaflet.beat
*   **Mobile Runtime:** Capacitor (Android)
*   **Icons & UI:** Lucide React

## 📦 Installation & Setup

Follow these steps to run the project locally.

### 1. Clone the Repository

```bash
git clone [https://github.com/your-username/sentra.git](https://github.com/your-username/sentra.git)
cd sentra

2. Install Dependencies
bash
npm install
3. Environment Configuration
Create a .env file in the root directory and add your Firebase configuration keys:

env
VITE_FIREBASE_API_KEY=your_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_storage_bucket
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
4. Run Development Server
bash
npm run dev
The app will launch at http://localhost:5173.

📱 Mobile Build (Android)
To sync and run the Android version:

bash
npm run build
npx cap sync
npx cap open android
📂 Project Structure
text
src/
├── components/       # Reusable UI components
├── context/          # React Context (Auth, Global State)
├── pages/            # Main Views (Dashboard, Map, Login)
├── services/         # Firebase & API Logic
│   ├── firebase.ts          # Core Config
│   └── incidents.service.ts # Incident CRUD & Verification
├── utils/            # Helper Algorithms
│   ├── deduplication.ts     # Duplicate detection logic
│   └── priority.ts          # Severity scoring algorithm
├── App.tsx           # Main Router
└── main.tsx          # Entry Point
🤝 Contributing
Contributions are welcome! Please fork the repository and create a pull request for any feature enhancements or bug fixes.

Fork the Project
Create your Feature Branch (git checkout -b feature/AmazingFeature)
Commit your Changes (git commit -m 'Add some AmazingFeature')
Push to the Branch (git push origin feature/AmazingFeature)
Open a Pull Request
📄 License
Distributed under the MIT License. See LICENSE for more information.
