import { db } from "./firebase";
import {
  collection,
  addDoc,
  doc,
  updateDoc,
  arrayUnion,
  increment,
  getDoc,
  serverTimestamp,
} from "firebase/firestore";

import type { Incident, Status } from "../types/Incident";

/* =====================
   CREATE INCIDENT
===================== */
export const createIncident = async (
  incident: Omit<
    Incident,
    | "id"
    | "status"
    | "createdAt"
    | "sensorVerified"
    | "confidence"
  >
) => {
  try {
    const docRef = await addDoc(collection(db, "incidents"), {
      ...incident,
      status: "Reported" as Status,
      createdAt: serverTimestamp(),
      crowdVerifyCount: 0,
      crowdVerifiedBy: [],
      sensorVerified: false,
      confidence: 40,
    });

    // 🔥 Sync to SQL
    await fetch("http://localhost:5000/report", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        user_id: 1,
        type: incident.type,
        severity: incident.severity,
        confidence: 40,
      }),
    });

    return docRef.id;

  } catch (error) {
    console.error("Incident creation failed:", error);
    throw error;
  }
};

/* =====================
   CROWD VERIFY
===================== */
export const crowdVerifyIncident = async (
  id: string,
  userId: string
) => {
  const ref = doc(db, "incidents", id);
  const snap = await getDoc(ref);

  if (!snap.exists()) return;

  const data = snap.data();

  if (data.crowdVerifiedBy?.includes(userId)) {
    console.warn("Already verified");
    return;
  }

  await updateDoc(ref, {
    crowdVerifyCount: increment(1),
    crowdVerifiedBy: arrayUnion(userId),
    status: "Verified" as Status,
    confidence: increment(10),
  });
};

/* =====================
   SENSOR VERIFY
===================== */
export const verifyViaSensor = async (id: string) => {
  await updateDoc(doc(db, "incidents", id), {
    sensorVerified: true,
    status: "Verified" as Status,
    confidence: increment(25),
  });
};

/* =====================
   STATUS UPDATE
===================== */
export const updateIncidentStatus = async (
  id: string,
  status: Status
) => {
  await updateDoc(doc(db, "incidents", id), { status });
};