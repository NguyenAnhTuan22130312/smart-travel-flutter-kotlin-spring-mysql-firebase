import React, { use, useEffect, useState } from 'react';
import { Menu, LogOut, Home, MapPin, Hotel, MapPinned, Calendar, Tag, Users, BarChart3, TrendingUp, Users2, Map, ArrowUp, ArrowDown, Bell, Settings, Search } from 'lucide-react';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';
import Sidebar from '../components/shared/Sidebar';

const AdminDashboard = () => {
  const [currentPage, setCurrentPage] = useState('dashboard');
  const [notificationOpen, setNotificationOpen] = useState(false);

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


  const handleLogout = () => {
    if (window.confirm('Bạn chắc chắn muốn đăng xuất?')) {
      localStorage.removeItem('token');
      localStorage.removeItem('role');
      window.location.href = '/login';
    }
  };


  // Data for charts
  const revenueData = [
    { month: 'T1', revenue: 40000, booking: 24 },
    { month: 'T2', revenue: 30000, booking: 13 },
    { month: 'T3', revenue: 20000, booking: 9 },
    { month: 'T4', revenue: 27800, booking: 39 },
    { month: 'T5', revenue: 18900, booking: 48 },
    { month: 'T6', revenue: 23900, booking: 38 },
    { month: 'T7', revenue: 34900, booking: 43 },
  ];

  const destinationData = [
    { name: 'Hà Nội', value: 28, color: '#3B82F6' },
    { name: 'Hồ Chí Minh', value: 35, color: '#10B981' },
    { name: 'Đà Nẵng', value: 20, color: '#F59E0B' },
    { name: 'Khác', value: 17, color: '#8B5CF6' },
  ];

  const stats = [
    {
      title: 'Tổng Đặt Phòng',
      value: '1,234',
      change: '+12.5%',
      isIncrease: true,
      icon: Calendar,
      color: 'blue',
      bgColor: 'bg-blue-50'
    },
    {
      title: 'Doanh Thu',
      value: '₫234.5M',
      change: '+8.2%',
      isIncrease: true,
      icon: BarChart3,
      color: 'green',
      bgColor: 'bg-green-50'
    },
    {
      title: 'Người Dùng',
      value: '5,642',
      change: '+5.3%',
      isIncrease: true,
      icon: Users2,
      color: 'purple',
      bgColor: 'bg-purple-50'
    },
    {
      title: 'Địa Điểm',
      value: '342',
      change: '-2.1%',
      isIncrease: false,
      icon: Map,
      color: 'orange',
      bgColor: 'bg-orange-50'
    },
  ];

  const recentBookings = [
    { id: 1, user: 'Nguyễn Văn A', hotel: 'Vinpearl Hanoi', date: '2024-01-15', amount: '₫2.5M', status: 'Confirmed' },
    { id: 2, user: 'Trần Thị B', hotel: 'Saigon Hotel', date: '2024-01-14', amount: '₫3.2M', status: 'Pending' },
    { id: 3, user: 'Phạm Văn C', hotel: 'Da Nang Beach', date: '2024-01-13', amount: '₫1.8M', status: 'Confirmed' },
    { id: 4, user: 'Hoàng Thị D', hotel: 'Luxury Resort', date: '2024-01-12', amount: '₫4.5M', status: 'Cancelled' },
    { id: 5, user: 'Vũ Văn E', hotel: 'Mountain Lodge', date: '2024-01-11', amount: '₫2.1M', status: 'Confirmed' },
  ];

  const topDestinations = [
    { rank: 1, name: 'Hà Nội', visits: 15420, rating: 4.8 },
    { rank: 2, name: 'Hồ Chí Minh', visits: 14230, rating: 4.7 },
    { rank: 3, name: 'Đà Nẵng', visits: 9850, rating: 4.9 },
    { rank: 4, name: 'Nha Trang', visits: 8420, rating: 4.6 },
    { rank: 5, name: 'Sapa', visits: 6750, rating: 4.8 },
  ];

  return (
    <div className="flex min-h-screen bg-slate-100">
      {/* Main Content */}
      <div className={'flex-1 transition-all duration-300'}>
        {/* Top Bar */}
        <div className="bg-white shadow-md sticky top-0 z-40">
          <div className="p-6 flex items-center justify-between">
            <div className="flex-1">
              <h2 className="text-2xl font-bold text-slate-800">Dashboard</h2>
              <p className="text-slate-600">Xin chào, Admin! 👋</p>
            </div>

            <div className="flex items-center gap-4">
              <div className="hidden md:flex relative">
                <Search className="absolute left-3 top-3 text-slate-400" size={20} />
                <input
                  type="text"
                  placeholder="Tìm kiếm..."
                  className="pl-10 pr-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-blue-500"
                />
              </div>

              <button className="relative p-2 hover:bg-slate-100 rounded-lg transition">
                <Bell size={20} className="text-slate-600" />
                <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
              </button>

              <button className="p-2 hover:bg-slate-100 rounded-lg transition">
                <Settings size={20} className="text-slate-600" />
              </button>

              <div className="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center text-white font-bold cursor-pointer hover:bg-blue-600">
                A
              </div>
            </div>
          </div>
        </div>

        {/* Dashboard Content */}
        {currentPage === 'dashboard' && (
          <div className="p-8">
            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
              {stats.map((stat, idx) => (
                <div key={idx} className="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition">
                  <div className="flex items-start justify-between mb-4">
                    <div className={`${stat.bgColor} p-3 rounded-lg`}>
                      <stat.icon size={24} className={`text-${stat.color}-600`} />
                    </div>
                    <div className={`flex items-center gap-1 text-sm font-semibold ${stat.isIncrease ? 'text-green-600' : 'text-red-600'}`}>
                      {stat.isIncrease ? <ArrowUp size={16} /> : <ArrowDown size={16} />}
                      {stat.change}
                    </div>
                  </div>
                  <h3 className="text-slate-600 text-sm mb-1">{stat.title}</h3>
                  <p className="text-2xl font-bold text-slate-800">{stat.value}</p>
                </div>
              ))}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
              {/* Revenue Chart */}
              <div className="lg:col-span-2 bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-bold text-slate-800 mb-4">Doanh Thu & Đặt Phòng</h3>
                <ResponsiveContainer width="100%" height={300}>
                  <LineChart data={revenueData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="month" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Line type="monotone" dataKey="revenue" stroke="#3B82F6" name="Doanh Thu (triệu)" />
                    <Line type="monotone" dataKey="booking" stroke="#10B981" name="Đặt Phòng" />
                  </LineChart>
                </ResponsiveContainer>
              </div>

              {/* Destination Distribution */}
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-bold text-slate-800 mb-4">Phân Bố Địa Điểm</h3>
                <ResponsiveContainer width="100%" height={300}>
                  <PieChart>
                    <Pie data={destinationData} cx="50%" cy="50%" labelLine={false} label={({ name, value }) => `${name}: ${value}`} outerRadius={80} fill="#8884d8" dataKey="value">
                      {destinationData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              {/* Recent Bookings */}
              <div className="lg:col-span-2 bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-bold text-slate-800 mb-4">Đặt Phòng Gần Đây</h3>
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead className="border-b-2 border-slate-200">
                      <tr>
                        <th className="text-left py-3 text-slate-600 font-semibold">Người Dùng</th>
                        <th className="text-left py-3 text-slate-600 font-semibold">Khách Sạn</th>
                        <th className="text-left py-3 text-slate-600 font-semibold">Ngày</th>
                        <th className="text-left py-3 text-slate-600 font-semibold">Giá</th>
                        <th className="text-left py-3 text-slate-600 font-semibold">Trạng Thái</th>
                      </tr>
                    </thead>
                    <tbody>
                      {recentBookings.map((booking) => (
                        <tr key={booking.id} className="border-b border-slate-200 hover:bg-slate-50">
                          <td className="py-3">{booking.user}</td>
                          <td className="py-3">{booking.hotel}</td>
                          <td className="py-3">{booking.date}</td>
                          <td className="py-3 font-semibold">{booking.amount}</td>
                          <td className="py-3">
                            <span className={`px-3 py-1 rounded-full text-xs font-semibold ${
                              booking.status === 'Confirmed' ? 'bg-green-100 text-green-800' :
                              booking.status === 'Pending' ? 'bg-yellow-100 text-yellow-800' :
                              'bg-red-100 text-red-800'
                            }`}>
                              {booking.status}
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Top Destinations */}
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-bold text-slate-800 mb-4">Top Địa Điểm</h3>
                <div className="space-y-4">
                  {topDestinations.map((dest) => (
                    <div key={dest.rank} className="flex items-center justify-between p-3 bg-slate-50 rounded-lg hover:bg-slate-100 transition">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center text-white font-bold text-sm">
                          {dest.rank}
                        </div>
                        <div>
                          <p className="font-semibold text-slate-800">{dest.name}</p>
                          <p className="text-xs text-slate-600">{dest.visits.toLocaleString()} lượt</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-1">
                        <span className="text-sm font-bold text-slate-800">{dest.rating}</span>
                        <span className="text-yellow-400">⭐</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Other Pages Placeholder */}
        {currentPage !== 'dashboard' && (
          <div className="p-8">
            <div className="bg-white rounded-lg shadow-md p-12 text-center">
              <h2 className="text-2xl font-bold text-slate-800 mb-2">Trang {menuItems.find(m => m.id === currentPage)?.label}</h2>
              <p className="text-slate-600">Tính năng này sẽ sớm được triển khai...</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default AdminDashboard;