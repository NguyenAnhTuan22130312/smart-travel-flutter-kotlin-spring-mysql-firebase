import React, { useState } from 'react';
import { Menu, LogOut, Home, MapPin, Hotel, MapPinned, Calendar, Tag, Users } from 'lucide-react';
import { logoutAdmin } from '../../service/Auth';
import { toast } from 'react-toastify';
import { useNavigate } from 'react-router-dom';

const Sidebar = ({ sidebarOpen, setSidebarOpen, currentPage, setCurrentPage, onLogout }) => {
  const [showLogoutModal, setShowLogoutModal] = useState(false);
  const navigate = useNavigate()

  const menuItems = [
    { id: 'dashboard', icon: Home, label: 'Dashboard' },
    { id: 'provinces', icon: MapPin, label: 'Tỉnh Thành' },
    { id: 'destinations', icon: MapPinned, label: 'Địa Điểm' },
    { id: 'hotels', icon: Hotel, label: 'Khách Sạn' },
    { id: 'tours', icon: MapPinned, label: 'Tour' },
    { id: 'bookings', icon: Calendar, label: 'Lịch Đặt' },
    { id: 'promotions', icon: Tag, label: 'Khuyến Mãi' },
    { id: 'users', icon: Users, label: 'Người Dùng' },
  ];

  const handleLogout = async () => {
    try {
      await logoutAdmin(); // Gọi API logout
      setShowLogoutModal(false);
      window.location.href = "/login"
    } catch (error) {
      toast.error("Logout failed:", error);
    }
  };

  return (
    <>
      <div className={`${sidebarOpen ? 'w-64' : 'w-20'} bg-gradient-to-b from-blue-600 to-blue-800 text-white transition-all duration-300 shadow-lg flex flex-col`}>
        <div className="p-4 flex items-center justify-between">
          {sidebarOpen && <h1 className="text-xl font-bold">Smart Travel</h1>}
          <button onClick={() => setSidebarOpen(!sidebarOpen)} className="hover:bg-blue-700 p-2 rounded">
            <Menu size={20} />
          </button>
        </div>
        
        <nav className="mt-8 space-y-2 px-2 flex-1">
          {menuItems.map(item => (
            <button
  key={item.id}
  onClick={() => {
    setCurrentPage(item.id);
    // Chuyển route dựa trên id
    switch(item.id) {
      case 'dashboard':
        navigate('/dashboard');
        break;
      case 'provinces':
        navigate('/provinces');
        break;
      case 'destinations':
        navigate('/destinations');
        break;
      case 'hotels':
        navigate('/hotels');
        break;
      case 'tours':
        navigate('/tours');
        break;
      case 'bookings':
        navigate('/bookings');
        break;
      case 'promotions':
        navigate('/promotions');
        break;
      case 'users':
        navigate('/users');
        break;
      default:
        navigate('/dashboard');
    }
  }}
  className={`w-full flex items-center space-x-3 p-3 rounded-lg transition ${
    currentPage === item.id ? 'bg-blue-500 shadow-lg' : 'hover:bg-blue-700'
  }`}
>
  <item.icon size={20} />
  {sidebarOpen && <span>{item.label}</span>}
</button>
          ))}
        </nav>

        {/* Logout Button */}
        <div className="p-2 border-t border-blue-700">
          <button
            onClick={() => setShowLogoutModal(true)}
            className="w-full flex items-center space-x-3 p-3 rounded-lg hover:bg-blue-700 transition text-red-200 hover:text-white"
          >
            <LogOut size={20} />
            {sidebarOpen && <span>Đăng Xuất</span>}
          </button>
        </div>
      </div>

      {/* Modal Xác Nhận Đăng Xuất */}
      {showLogoutModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-96 shadow-xl">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Xác nhận đăng xuất</h3>
            <p className="text-gray-600 mb-6">Bạn có chắc chắn muốn đăng xuất khỏi hệ thống?</p>
            <div className="flex justify-end space-x-3">
              <button
                onClick={() => setShowLogoutModal(false)}
                className="px-4 py-2 bg-gray-200 text-gray-700 rounded hover:bg-gray-300 transition"
              >
                Hủy
              </button>
              <button
                onClick={handleLogout}
                className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition"
              >
                Đăng Xuất
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default Sidebar;