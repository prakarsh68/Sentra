import { Routes, Route, Navigate } from "react-router-dom";
import { useAuth } from "./context/AuthContext";
import Navbar from "./components/Navbar";

import Home from "./pages/Home";
import Login from "./pages/Login";
import Register from "./pages/Register";
import Report from "./pages/Report";
import Dashboard from "./pages/Dashboard";
import MapView from "./pages/MapView";
import OperationsView from "./pages/OperationsView";

function App() {
  const { user, role, loading } = useAuth();
  if (loading) return null;

  return (
    <>
      <Navbar />
     <Routes>
  <Route path="/" element={<Home />} />

  <Route path="/login" element={!user ? <Login /> : <Navigate to="/" />} />
  <Route path="/register" element={!user ? <Register /> : <Navigate to="/" />} />

  <Route path="/operations" element={<OperationsView />} />

  {/* Citizen Route */}
  <Route
    path="/report"
    element={
      user && role === "citizen" ? (
        <Report />
      ) : (
        <Navigate to="/login" />
      )
    }
  />

  {/* Responder Routes */}
  <Route
    path="/dashboard"
    element={
      user && role === "responder" ? (
        <Dashboard />
      ) : (
        <Navigate to="/login" />
      )
    }
  />

  <Route
    path="/map"
    element={
      user && role === "responder" ? (
        <MapView />
      ) : (
        <Navigate to="/login" />
      )
    }
  />

  <Route path="*" element={<Navigate to="/" />} />
</Routes>
    </>
  );
}

export default App;
