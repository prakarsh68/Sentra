export const getIncidentAnalytics = async () => {
  const response = await fetch("http://localhost:5000/analytics");

  if (!response.ok) {
    throw new Error("Failed to fetch analytics");
  }

  return response.json();
};