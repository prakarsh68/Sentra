import { useEffect, useState } from "react";
import { collection, onSnapshot } from "firebase/firestore";
import { db } from "../services/firebase";
import { getIncidentAnalytics } from "../services/sqlService";

import {
  updateIncidentStatus,
  verifyViaSensor,
  crowdVerifyIncident,
} from "../services/incidents.service";

import { calculatePriorityWithReasons } from "../utils/priority";
import { isPotentialDuplicate } from "../utils/deduplication";

/* =====================
   TYPES
===================== */

interface Incident {
  id: string;
  type?: string;
  severity?: "Low" | "Medium" | "Critical";
  status?: "Reported" | "Verified" | "Assigned" | "Resolved";
  createdAt?: any;
  location?: { lat: number; lng: number };
  sensorVerified?: boolean;
  crowdVerifyCount?: number;
  priority?: number;
  reasons?: string[];
  isDuplicate?: boolean;
}

interface Analytics {
  type: string;
  total: number;
}

/* =====================
   CONSTANTS
===================== */

const QUOTES = [
  "Clarity saves time. Time saves lives.",
  "Every calm decision makes a difference.",
  "Respond with focus. Act with purpose.",
  "Information becomes impact when understood.",
  "Precision is the first step to safety.",
];

const RESPONDER_CENTER = { lat: 20.5937, lng: 78.9629 };

/* =====================
   HELPERS
===================== */

function safeDate(createdAt: any): Date {
  try {
    if (!createdAt) return new Date();
    if (typeof createdAt.toDate === "function") return createdAt.toDate();
    if (createdAt.seconds) return new Date(createdAt.seconds * 1000);
    const d = new Date(createdAt);
    return isNaN(d.getTime()) ? new Date() : d;
  } catch {
    return new Date();
  }
}

function distanceKm(lat1: number, lng1: number, lat2: number, lng2: number) {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;

  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) ** 2;

  return 2 * R * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

/* =====================
   COMPONENT
===================== */

export default function Dashboard() {
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [analytics, setAnalytics] = useState<Analytics[]>([]);
  const [quoteIndex, setQuoteIndex] = useState(0);

  const SESSION_ID =
    sessionStorage.getItem("sentra_user") ??
    (() => {
      const id = crypto.randomUUID();
      sessionStorage.setItem("sentra_user", id);
      return id;
    })();

  /* =====================
     ROTATING QUOTE
  ===================== */

  useEffect(() => {
    const t = setInterval(
      () => setQuoteIndex((i) => (i + 1) % QUOTES.length),
      6000
    );
    return () => clearInterval(t);
  }, []);

  /* =====================
     FIREBASE INCIDENTS
  ===================== */

  useEffect(() => {
    const unsubscribe = onSnapshot(collection(db, "incidents"), (snap) => {
      const data = snap.docs.map((doc) => ({
        id: doc.id,
        ...(doc.data() as any),
      }));
      setIncidents(data);
    });

    return () => unsubscribe();
  }, []);

  /* =====================
     SQL ANALYTICS
  ===================== */

  useEffect(() => {
    getIncidentAnalytics().then(setAnalytics);
  }, []);

  /* =====================
     PROCESS INCIDENTS
  ===================== */

  const processed = incidents.map((i, idx, self) => {
    const result = calculatePriorityWithReasons(
      i.severity || "Low",
      i.status || "Reported",
      safeDate(i.createdAt),
      i.sensorVerified || false
    );

    const isDuplicate = isPotentialDuplicate(
      i,
      self.filter((_, index) => index !== idx)
    );

    return {
      ...i,
      priority: result.score,
      reasons: result.reasons,
      isDuplicate,
    };
  });

  const sorted = [...processed].sort((a, b) => b.priority! - a.priority!);

  return (
    <main className="min-h-screen bg-[#020617] text-slate-100 px-6 py-10">

      {/* HEADER */}
      <section className="max-w-7xl mx-auto mb-10">
        <div className="rounded-3xl p-8 bg-slate-900 border border-white/10 shadow-2xl">
          <h1 className="text-3xl font-bold bg-gradient-to-r from-teal-400 to-blue-500 bg-clip-text text-transparent">
            Emergency Operations Dashboard
          </h1>

          <p className="text-sm italic text-slate-400 mt-2">
            “{QUOTES[quoteIndex]}”
          </p>
        </div>
      </section>

      {/* SQL ANALYTICS PANEL */}
      <section className="max-w-7xl mx-auto mb-8">
        <div className="grid grid-cols-3 gap-4">
          {analytics.map((a) => (
            <div
              key={a.type}
              className="p-6 rounded-xl bg-slate-900 border border-white/10"
            >
              <p className="text-sm text-slate-400">{a.type}</p>
              <h2 className="text-3xl font-bold text-teal-400">{a.total}</h2>
              <p className="text-xs text-slate-500">Total Incidents</p>
            </div>
          ))}
        </div>
      </section>

      {/* INCIDENT LIST */}
      <section className="max-w-7xl mx-auto space-y-4">
        {sorted.map((i) => (
          <div
            key={i.id}
            className="relative rounded-2xl bg-slate-900/40 border border-white/10 px-7 py-6 overflow-hidden"
          >
            <div
              className={`absolute left-0 top-0 h-full w-1 ${
                i.severity === "Critical"
                  ? "bg-red-500"
                  : i.severity === "Medium"
                  ? "bg-orange-400"
                  : "bg-emerald-400"
              }`}
            />

            <div className="grid grid-cols-12 gap-6 items-center">

              <div className="col-span-4">
                <span className="text-sm font-bold">{i.type}</span>
              </div>

              <div className="col-span-2 text-center">
                <p className="text-3xl font-black text-teal-400">
                  {i.priority}
                </p>
              </div>

              <div className="col-span-3 text-xs text-slate-400">
                {i.reasons?.slice(0, 2).join(" • ")}
              </div>

              <div className="col-span-3 flex justify-end gap-2">

                {!i.sensorVerified && (
                  <button
                    onClick={() => crowdVerifyIncident(i.id, SESSION_ID)}
                    className="px-3 py-2 text-[10px] bg-white/5 border border-white/10 rounded-lg"
                  >
                    Verify
                  </button>
                )}

                {i.status !== "Resolved" && (
                  <button
                    onClick={() => updateIncidentStatus(i.id, "Resolved")}
                    className="px-4 py-2 text-[10px] bg-emerald-600 rounded-lg"
                  >
                    Resolve
                  </button>
                )}

              </div>
            </div>
          </div>
        ))}
      </section>
    </main>
  );
}