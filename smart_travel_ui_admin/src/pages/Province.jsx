import React, { useEffect, useState, useCallback } from 'react'; // Thêm useCallback
import {
  Edit2,
  Trash2,
  Plus,
  Search,
  ChevronLeft,
  ChevronRight,
  X,
  Upload,
  Loader2,
  Image as ImageIcon,
  Landmark,
  SearchX,
} from 'lucide-react';
// Giả sử bạn đã import các service này
import { 
  getAllProvince, 
  addProvince, 
  editProvince, 
  deleteProvince 
} from '../service/province'; 
import { toast, ToastContainer } from 'react-toastify';
import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css";


const TableLoadingSpinner = ({ colSpan }) => (
  <tr>
    <td colSpan={colSpan} className="px-6 py-12 text-center">
      <div className="flex justify-center items-center gap-2 text-slate-500">
        <Loader2 className="animate-spin" size={20} />
        <span>Đang tải dữ liệu...</span>
      </div>
    </td>
  </tr>
);

// (Component EmptyState)
const EmptyState = ({ colSpan }) => (
  <tr>
    <td colSpan={colSpan} className="px-6 py-12 text-center text-slate-500">
      <SearchX size={40} className="mx-auto mb-3 text-slate-400" />
      <p className="text-lg font-medium">Không tìm thấy tỉnh thành</p>
      <p className="text-sm">Hãy thử thay đổi từ khóa tìm kiếm của bạn.</p>
    </td>
  </tr>
);

const ProvinceManagement = () => {
  const [provinces, setProvinces] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const [currentPage, setCurrentPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState(null);

  const [imagePreview, setImagePreview] = useState(null);
  const [imageFile, setImageFile] = useState(null);

  const [formData, setFormData] = useState({
    name: '',
    code: '',
    region: '',
    description: '',
    isPopular: false,
    imageUrl: '',
  });

  // Tách hàm fetch ra để có thể gọi lại
  const fetchProvinces = useCallback(async () => {
    setIsLoading(true);
    try {
      const response = await getAllProvince();
      setProvinces(response.data.data);
    } catch (err) {
      toast.error("Có lỗi xảy ra khi tải danh sách tỉnh thành");
    } finally {
      setIsLoading(false);
    }
  }, []); // useCallback với dependency rỗng

  // Fetch data lần đầu khi component mount
  useEffect(() => {
    fetchProvinces();
  }, [fetchProvinces]);

  // Logic phân trang và filter (giữ nguyên)
  const itemsPerPage = 5;
  const filteredProvinces = provinces.filter(p =>
    p.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    p.code.toLowerCase().includes(searchTerm.toLowerCase())
  );
  const totalPages = Math.ceil(filteredProvinces.length / itemsPerPage);
  const startIdx = (currentPage - 1) * itemsPerPage;
  const displayedProvinces = filteredProvinces.slice(startIdx, startIdx + itemsPerPage);

  // Xử lý modal (giữ nguyên)
  const resetFormData = () => {
    setFormData({ name: '', code: '', region: '', description: '', isPopular: false, imageUrl: '' });
    setImagePreview(null);
    setImageFile(null);
    setEditingId(null);
  };

  const handleOpenModal = (province = null) => {
    if (province) {
      setFormData(province);
      setImagePreview(province.imageUrl);
      setEditingId(province.id);
    } else {
      resetFormData();
    }
    setShowModal(true);
  };

  const handleCloseModal = () => {
    if (imagePreview && imagePreview.startsWith('blob:')) {
      URL.revokeObjectURL(imagePreview);
    }
    setShowModal(false);
    resetFormData();
  };

  // Xử lý logic Thêm / Cập nhật
  const handleSubmit = async () => {
    if (!formData.name || !formData.code || !formData.region) {
      toast.warn('Vui lòng điền đủ Tên, Mã và Miền');
      return;
    }

    setIsSubmitting(true);
    
    // 1. Chuẩn bị FormData
    const dataToSubmit = new FormData();
    
    // 2. Tạo đối tượng JSON cho phần "data"
    // (Loại bỏ imageUrl vì nó được quản lý bởi file upload)
    const provinceData = {
      name: formData.name,
      code: formData.code,
      region: formData.region,
      description: formData.description,
      isPopular: formData.isPopular,
    };

    // 3. Append phần JSON
    // Backend Spring Boot mong đợi một Blob với kiểu application/json
    dataToSubmit.append(
      'data', 
      new Blob([JSON.stringify(provinceData)], { type: "application/json" })
    );

    // 4. Append phần hình ảnh (nếu có)
    if (imageFile) {
      dataToSubmit.append('image', imageFile);
    }

    // 5. Gọi API
    try {
      if (editingId) {
        // --- GỌI API CẬP NHẬT ---
        await editProvince(editingId, dataToSubmit);
        toast.success('Cập nhật tỉnh thành thành công!');
      } else {
        // --- GỌI API THÊM MỚI ---
        await addProvince(dataToSubmit);
        toast.success('Thêm tỉnh thành thành công!');
      }
      
      handleCloseModal();
      await fetchProvinces(); // Tải lại dữ liệu mới
    } catch (error) {
      // Lấy lỗi từ response (nếu có)
      const errorMsg = error.response?.data?.msg || 'Đã xảy ra lỗi khi lưu!';
      toast.error(errorMsg);
    } finally {
      setIsSubmitting(false);
    }
  };

  // Xử lý logic Xóa
  const handleDelete = async (id) => {
    if (window.confirm('Bạn chắc chắn muốn xóa tỉnh thành này? Thao tác này có thể ảnh hưởng đến các dữ liệu liên quan.')) {
      try {
        // --- GỌI API XÓA ---
        await deleteProvince(id);
        toast.success('Xóa tỉnh thành thành công');
        
        // Điều chỉnh trang nếu xóa item cuối cùng
        if (displayedProvinces.length === 1 && currentPage > 1) {
          setCurrentPage(currentPage - 1);
        }
        
        await fetchProvinces(); // Tải lại dữ liệu
      } catch (error) {
        // Lấy lỗi từ response (nếu có)
        const errorMsg = error.response?.data?.msg || 'Xóa thất bại! Đã xảy ra lỗi.';
        toast.error(errorMsg);
      }
    }
  };

  // Xử lý upload ảnh (giữ nguyên)
  const handleImageChange = (e) => {
    const file = e.target.files?.[0];
    if (file) {
      if (file.size > 5 * 1024 * 1024) {
        toast.warn("Kích thước tệp quá lớn. Vui lòng chọn tệp dưới 5MB.");
        return;
      }
      if (imagePreview && imagePreview.startsWith('blob:')) {
        URL.revokeObjectURL(imagePreview);
      }
      setImageFile(file);
      const previewUrl = URL.createObjectURL(file);
      setImagePreview(previewUrl);
    }
  };

  const handleRemoveImage = () => {
    if (imagePreview && imagePreview.startsWith('blob:')) {
      URL.revokeObjectURL(imagePreview);
    }
    setImagePreview(null);
    setImageFile(null);
    if (editingId) {
      setImagePreview(formData.imageUrl);
    }
  }

  // --- PHẦN JSX (return) GIỮ NGUYÊN ---
  return (
    <div className="flex-1 p-6 md:p-8 bg-slate-50 min-h-screen">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-slate-800">Quản Lý Tỉnh Thành</h1>
        <p className="text-slate-600 mt-1">Quản lý danh sách tỉnh thành và các thông tin liên quan</p>
      </div>

      {/* Toolbar */}
      <div className="bg-white rounded-lg shadow-sm p-4 md:p-6 mb-6">
        <div className="flex flex-col md:flex-row gap-4 items-center justify-between">
          <div className="flex-1 w-full md:max-w-md">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
              <input
                type="text"
                placeholder="Tìm kiếm theo tên hoặc mã..."
                className="w-full pl-10 pr-4 py-2.5 border border-slate-300 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                value={searchTerm}
                onChange={(e) => {
                  setSearchTerm(e.target.value);
                  setCurrentPage(1);
                }}
              />
            </div>
          </div>
          <button
            onClick={() => handleOpenModal()}
            className="flex w-full md:w-auto items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-5 py-2.5 rounded-lg transition font-medium shadow-md hover:shadow-lg"
          >
            <Plus size={20} />
            <span>Thêm Tỉnh Thành</span>
          </button>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-lg shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Hình ảnh</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Tên Tỉnh</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Mã</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Miền</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Trạng Thái</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Điểm Đến</th>
                <th className="px-6 py-3 text-center text-xs font-medium text-slate-500 uppercase tracking-wider">Hành Động</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {isLoading ? (
                <TableLoadingSpinner colSpan={7} />
              ) : displayedProvinces.length > 0 ? (
                displayedProvinces.map((province) => (
                  <tr key={province.id} className="hover:bg-slate-50 transition">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        {/* Cập nhật điều kiện check: chỉ hiển thị nếu imageUrl tồn tại */}
                        {province.imageUrl ? (
                          <img className="h-12 w-16 rounded-lg object-cover" src={province.imageUrl} alt={province.name} />
                        ) : (
                          <div className="h-12 w-16 rounded-lg bg-slate-100 flex items-center justify-center">
                            <Landmark size={24} className="text-slate-400" />
                          </div>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="font-medium text-slate-800">{province.name}</span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="bg-slate-100 text-slate-700 px-3 py-1 rounded-full text-sm font-medium">{province.code}</span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-slate-700">{province.region}</td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-3 py-1 rounded-full text-xs font-semibold ${province.isPopular ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}`}>
                        {province.isPopular ? 'Nổi bật' : 'Thường'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-700 font-medium">
                      {/* Hiển thị '0' nếu destinationCount không có */}
                      {province.destinationCount || 0}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex gap-2 justify-center">
                        <button
                          onClick={() => handleOpenModal(province)}
                          className="p-2 bg-yellow-100 hover:bg-yellow-200 text-yellow-700 rounded-lg transition"
                          title="Chỉnh sửa"
                        >
                          <Edit2 size={18} />
                        </button>
                        <button
                          onClick={() => handleDelete(province.id)}
                          className="p-2 bg-red-100 hover:bg-red-200 text-red-700 rounded-lg transition"
                          title="Xóa"
                        >
                          <Trash2 size={18} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <EmptyState colSpan={7} />
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="bg-white px-4 py-3 border-t border-slate-200 flex items-center justify-between flex-wrap gap-4">
            <div className="text-sm text-slate-600">
              Hiển thị <span className="font-semibold">{startIdx + 1}</span> - <span className="font-semibold">{Math.min(startIdx + itemsPerPage, filteredProvinces.length)}</span> trên <span className="font-semibold">{filteredProvinces.length}</span>
            </div>
            <div className="flex gap-1 items-center">
              <button
                onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                disabled={currentPage === 1}
                className="p-2 hover:bg-slate-100 disabled:opacity-50 disabled:cursor-not-allowed rounded-lg transition"
              >
                <ChevronLeft size={20} />
              </button>
              
              <span className='text-sm font-medium text-slate-700'>
                Trang {currentPage} / {totalPages}
              </span>

              <button
                onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
                disabled={currentPage === totalPages}
                className="p-2 hover:bg-slate-100 disabled:opacity-50 disabled:cursor-not-allowed rounded-lg transition"
              >
                <ChevronRight size={20} />
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 transition-opacity duration-300">
          <div className="bg-white rounded-lg shadow-xl max-w-lg w-full max-h-[90vh] flex flex-col">
            {/* Modal Header */}
            <div className="flex items-center justify-between p-5 border-b border-slate-200">
              <h2 className="text-xl font-bold text-slate-800">
                {editingId ? 'Chỉnh Sửa Tỉnh Thành' : 'Thêm Tỉnh Thành Mới'}
              </h2>
              <button onClick={handleCloseModal} className="text-slate-400 hover:text-slate-600 p-1 rounded-full hover:bg-slate-100">
                <X size={22} />
              </button>
            </div>

            {/* Modal Body */}
            <div className="p-6 space-y-5 overflow-y-auto">
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1.5">Tên Tỉnh Thành *</label>
                <input
                  type="text"
                  className="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  placeholder="Nhập tên tỉnh thành"
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Mã *</label>
                  <input
                    type="text"
                    maxLength={10}
                    className="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
                    value={formData.code}
                    onChange={(e) => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
                    placeholder="VD: HCMC"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Miền *</label>
                  <select
                    className="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 bg-white"
                    value={formData.region}
                    onChange={(e) => setFormData({ ...formData, region: e.target.value })}
                  >
                    <option value="">Chọn miền</option>
                    <option value="Miền Bắc">Miền Bắc</option>
                    <option value="Miền Trung">Miền Trung</option>
                    <option value="Miền Nam">Miền Nam</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1.5">
                  Mô Tả
                </label>

                <ReactQuill
                  theme="snow"
                  className="border border-slate-300 rounded-lg"
                  value={formData.description}
                  onChange={(html) =>
                    setFormData({ ...formData, description: html })
                  }
                  placeholder="Nhập mô tả ngắn về tỉnh thành"
                />
              </div>

              {/* Image Upload Cải tiến */}
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1.5">Hình Ảnh</label>
                <div className="flex items-center gap-4">
                  <div className="w-24 h-24 rounded-lg border border-slate-300 overflow-hidden flex-shrink-0">
                    {imagePreview ? (
                      <img src={imagePreview} alt="Preview" className="w-full h-full object-cover" />
                    ) : (
                      <div className="w-full h-full bg-slate-100 flex items-center justify-center">
                        <ImageIcon size={32} className="text-slate-400" />
                      </div>
                    )}
                  </div>
                  <div className="flex-1">
                    <input
                      type="file"
                      id="imageInput"
                      accept="image/png, image/jpeg"
                      onChange={handleImageChange}
                      className="hidden"
                    />
                    <label htmlFor="imageInput" className="cursor-pointer inline-flex items-center gap-2 px-4 py-2 border border-slate-300 text-sm font-medium rounded-md text-slate-700 bg-white hover:bg-slate-50">
                      <Upload size={16} />
                      <span>{imageFile ? "Thay đổi ảnh" : "Tải ảnh lên"}</span>
                    </label>
                    <p className="text-xs text-slate-500 mt-2">PNG, JPG. Tối đa 5MB.</p>
                    {imagePreview && (
                      <button 
                        onClick={handleRemoveImage}
                        className="text-xs text-red-600 hover:text-red-800 mt-1 font-medium"
                      >
                        Xóa ảnh
                      </button>
                    )}
                  </div>
                </div>
              </div>

              <div className="flex items-center gap-3 pt-2">
                <input
                  type="checkbox"
                  id="isPopular"
                  checked={formData.isPopular}
                  onChange={(e) => setFormData({ ...formData, isPopular: e.target.checked })}
                  className="w-4 h-4 rounded text-blue-600 focus:ring-blue-500"
                />
                <label htmlFor="isPopular" className="text-sm font-medium text-slate-700 select-none">Đánh dấu là tỉnh thành nổi bật</label>
              </div>
            </div>

            {/* Modal Footer */}
            <div className="flex gap-3 p-5 border-t border-slate-200 bg-slate-50 rounded-b-lg">
              <button
                onClick={handleCloseModal}
                disabled={isSubmitting}
                className="flex-1 px-4 py-2.5 border border-slate-300 text-slate-700 rounded-lg hover:bg-slate-100 transition font-medium disabled:opacity-50"
              >
                Hủy
              </button>
              <button
                onClick={handleSubmit}
                disabled={isSubmitting}
                className="flex-1 px-4 py-2.5 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-medium disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                {isSubmitting ? (
                  <>
                    <Loader2 size={18} className="animate-spin" />
                    <span>Đang lưu...</span>
                  </>
                ) : (
                  editingId ? 'Cập Nhật' : 'Thêm Mới'
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ProvinceManagement;