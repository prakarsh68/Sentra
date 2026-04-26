// Severity level
export type Severity = "Low" | "Medium" | "Critical";

// Incident lifecycle status
export type Status =
  | "Reported"
  | "Verified"
  | "Assigned"
  | "Resolved";

// Supported incident categories
export type IncidentType =
  | "Smog"
  | "Fire"
  | "Medical"
  | "Accident";

// Core Incident interface
export interface Incident {
  id: string;

  type: IncidentType;
  severity: Severity;

  description: string; // ✅ FIXED

  status: Status;

  createdAt: any; // ✅ Firebase timestamp compatible

  location: {
    lat: number;
    lng: number;
    label?: string;
  };

  mediaUrl?: string | null; // ✅ optional media

  sensorVerified?: boolean;
  confidence?: number;

  crowdVerifyCount?: number;     // ✅ used in your logic
  crowdVerifiedBy?: string[];    // ✅ used in verify

  priority?: number; // ✅ used in dashboard
}