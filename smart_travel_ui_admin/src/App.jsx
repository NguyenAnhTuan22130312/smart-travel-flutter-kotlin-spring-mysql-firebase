import React, { useEffect, useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import ProvinceManagement from './pages/province';
import Sidebar from './components/shared/Sidebar';
import AdminDashboard from './pages/AdminDashboard';
import AdminLogin from './pages/LoginAdmin';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import DestinationManagement from './pages/DestinationManager';

export default function App() {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [currentPage, setCurrentPage] = useState('dashboard');
      return (
    <Router>
      <div className="flex h-screen bg-gray-100">
        {/* Sidebar chỉ hiện khi đã login */}
          <Sidebar
            sidebarOpen={sidebarOpen}
            setSidebarOpen={setSidebarOpen}
            currentPage= {currentPage}
            setCurrentPage={setCurrentPage}
          />
        <ToastContainer
        position="top-right"
        autoClose={3000} // tự ẩn sau 3s
        hideProgressBar={false}
        newestOnTop={false}
        closeOnClick
        rtl={false}
        pauseOnFocusLoss
        draggable
        pauseOnHover
      />

        <div className="flex-1 overflow-auto">
          <Routes>
            <Route
              path="/login"
              element={ <AdminLogin/>}
            />
            <Route
              path="/dashboard"
              element={ <AdminDashboard />}
            />
            <Route
              path="/provinces"
              element={ <ProvinceManagement /> }
            />
            <Route
              path="/destinations"
              element={ <DestinationManagement /> }
            />
         
          </Routes>
        </div>
      </div>
    </Router>
  );
}
