import React, { useEffect, useState, useCallback } from "react";
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
  SearchX,
  Star,
  Eye,
} from "lucide-react";
import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css";
import {
  create,
  deleteDestination,
  deleteDestinationImage,
  getAllDestinations,
  update,
} from "../service/Destination";
import { getAllProvince } from "../service/province";
import { toast } from "react-toastify";

const TableLoadingSpinner = ({ colSpan }) => (
  <tr>
    <td colSpan={colSpan} className="px-3 md:px-6 py-12 text-center">
      <div className="flex justify-center items-center gap-2 text-slate-500">
        <Loader2 className="animate-spin" size={20} />
        <span>Đang tải dữ liệu...</span>
      </div>
    </td>
  </tr>
);

const EmptyState = ({ colSpan }) => (
  <tr>
    <td
      colSpan={colSpan}
      className="px-3 md:px-6 py-12 text-center text-slate-500"
    >
      <SearchX size={40} className="mx-auto mb-3 text-slate-400" />
      <p className="text-lg font-medium">Không tìm thấy địa điểm</p>
      <p className="text-sm">Hãy thử thay đổi từ khóa tìm kiếm của bạn.</p>
    </td>
  </tr>
);

const DestinationManagement = () => {
  const [destinations, setDestinations] = useState([]);
  const [provinces, setProvinces] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const [currentPage, setCurrentPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("");
  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState(null);

  const [isDeletingImage, setIsDeletingImage] = useState(null);

  const [formData, setFormData] = useState({
    name: "",
    provinceId: "",
    description: "",
    category: "",
    latitude: "",
    longitude: "",
    address: "",
    entryFee: "",
    openingHours: "",
    openingHoursObj: {
      monday: "08:00 - 17:00",
      tuesday: "08:00 - 17:00",
      wednesday: "08:00 - 17:00",
      thursday: "08:00 - 17:00",
      friday: "08:00 - 17:00",
      saturday: "08:00 - 17:00",
      sunday: "08:00 - 17:00",
    },
    isFeatured: false,
  });

  const fetchDestinations = useCallback(async () => {
    setIsLoading(true);
    try {
      const res = await getAllDestinations();
      setDestinations(res?.data);
      console.log(res);
      const province = await getAllProvince();
      setProvinces(province.data.data);
    } catch (err) {
      console.error("Lỗi tải danh sách:", err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchDestinations();
  }, [fetchDestinations]);

  const itemsPerPage = 5;
  const filteredDestinations = destinations.filter(
    (d) =>
      (d.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        d.address.toLowerCase().includes(searchTerm.toLowerCase())) &&
      (!categoryFilter || d.category === categoryFilter)
  );

  const totalPages = Math.ceil(filteredDestinations.length / itemsPerPage);
  const startIdx = (currentPage - 1) * itemsPerPage;
  const displayedDestinations = filteredDestinations.slice(
    startIdx,
    startIdx + itemsPerPage
  );

  const categories = ["Biển", "Thiên nhiên", "Văn hóa", "Giải trí", "Thể thao"];

  //  ảnh cũ  vs ảnh mới
  const [existingImages, setExistingImages] = useState([]);
  const [newImagePreviews, setNewImagePreviews] = useState([]);
  const [newImageFiles, setNewImageFiles] = useState([]);
  const [imagesToDelete, setImagesToDelete] = useState([]);

  const resetFormData = () => {
    setFormData({
      name: "",
      provinceId: "",
      description: "",
      category: "",
      latitude: "",
      longitude: "",
      address: "",
      entryFee: "",
      openingHours: "",
      isFeatured: false,
    });
    setExistingImages([]);
    setNewImagePreviews([]);
    setNewImageFiles([]);
    setEditingId(null);
    setImagesToDelete([]);
  };

  const handleOpenModal = (destination = null) => {
    if (destination) {
      let hoursObj = {
        monday: "",
        tuesday: "",
        wednesday: "",
        thursday: "",
        friday: "",
        saturday: "",
        sunday: "",
      };
      // Parse dữ liệu giờ mở cửa từ backend
      if (destination.openingHours) {
      try {
        const parsed = JSON.parse(destination.openingHours);
        if (parsed && typeof parsed === "object") {
          // Ghi đè các ngày có dữ liệu từ server, giữ mặc định nếu không có
          hoursObj = { ...hoursObj, ...parsed };
        }
      } catch (e) {
        console.warn("Lỗi parse openingHours:", destination.openingHours);
      }
    }
      setFormData({
        name: destination.name,
        provinceId: destination.province.id,
        description: destination.description || "",
        category: destination.category,
        latitude: destination.latitude.toString(),
        longitude: destination.longitude.toString(),
        address: destination.address,
        entryFee: destination.entryFee || "",
        openingHoursObj: hoursObj,
        isFeatured: destination.isFeatured,
      });
      // Ảnh từ server
      setExistingImages(
        (destination.images || []).map((img) => ({
          id: img.id,
          url: img.imageUrl,
        }))
      );
      setNewImagePreviews([]);
      setNewImageFiles([]);
      setImagesToDelete([]);
      setEditingId(destination.id);
    } else {
      resetFormData();
    }
    setShowModal(true);
  };

  const handleCloseModal = () => {
    newImagePreviews.forEach((url) => {
      if (url.startsWith("blob:")) URL.revokeObjectURL(url);
    });
    setShowModal(false);
    resetFormData();
  };

  const handleSubmit = async () => {
    if (
      !formData.name ||
      !formData.provinceId ||
      !formData.latitude ||
      !formData.longitude
    ) {
      alert("Vui lòng điền đủ thông tin bắt buộc");
      return;
    }

    setIsSubmitting(true);

    try {
      // === BƯỚC 1: XÓA ẢNH CŨ TRƯỚC (nếu có) ===
      if (editingId && imagesToDelete.length > 0) {
        await Promise.all(
          imagesToDelete.map((imageId) =>
            deleteDestinationImage(editingId, imageId).catch((err) => {
              console.error("Lỗi xóa ảnh ID:", imageId, err);
            })
          )
        );
      }

      // === BƯỚC 2: Cập nhật/thêm địa điểm ===
      const dataToSubmit = new FormData();
      const destinationData = {
        name: formData.name,
        provinceId: parseInt(formData.provinceId),
        description: formData.description,
        category: formData.category,
        latitude: parseFloat(formData.latitude),
        longitude: parseFloat(formData.longitude),
        address: formData.address,
        entryFee: formData.entryFee ? parseFloat(formData.entryFee) : 0,
        openingHours: JSON.stringify(formData.openingHoursObj),
        isFeatured: formData.isFeatured,
      };

      dataToSubmit.append(
        "request",
        new Blob([JSON.stringify(destinationData)], {
          type: "application/json",
        })
      );

      if (newImageFiles.length > 0) {
        newImageFiles.forEach((file) => {
          dataToSubmit.append("imageFiles", file);
        });
      }

      if (editingId) {
        await update(editingId, dataToSubmit);
        toast.success("Cập nhật địa điểm thành công!");
      } else {
        await create(dataToSubmit);
        toast.success("Thêm địa điểm thành công!");
      }

      handleCloseModal();
      await fetchDestinations();
    } catch (error) {
      toast.error(
        "Đã xảy ra lỗi: " + (error.response?.data?.msg || "Lỗi hệ thống")
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm("Bạn chắc chắn muốn xóa địa điểm này?")) {
      try {
        await deleteDestination(id);
        toast.success("Xóa thành công");
        if (displayedDestinations.length === 1 && currentPage > 1) {
          setCurrentPage(currentPage - 1);
        }
        await fetchDestinations();
      } catch (error) {
        toast.error("Xóa thất bại");
      }
    }
  };

  const handleImageChange = (e) => {
    const files = Array.from(e.target.files || []);
    files.forEach((file) => {
      if (file.size > 5 * 1024 * 1024) {
        alert("Kích thước tệp quá lớn. Tối đa 5MB.");
        return;
      }
      const previewUrl = URL.createObjectURL(file);
      setNewImagePreviews((prev) => [...prev, previewUrl]);
      setNewImageFiles((prev) => [...prev, file]);
    });
  };

  // Xóa ảnh mới (chưa upload)
  const handleRemoveNewImage = (index) => {
    if (newImagePreviews[index].startsWith("blob:")) {
      URL.revokeObjectURL(newImagePreviews[index]);
    }
    setNewImagePreviews((prev) => prev.filter((_, i) => i !== index));
    setNewImageFiles((prev) => prev.filter((_, i) => i !== index));
  };

  const handleRemoveExistingImage = (index) => {
    const image = existingImages[index];

    // Ghi nhớ ID để xóa thật khi submit
    if (image?.id) {
      setImagesToDelete((prev) => [...prev, image.id]);
    }

    // Chỉ xóa khỏi giao diện
    setExistingImages((prev) => prev.filter((_, i) => i !== index));
  };

  return (
    <div className="flex-1 bg-slate-50 min-h-screen w-full overflow-hidden flex flex-col">
      {/* Header */}
      <div className="p-4 md:p-6 lg:p-8 border-b border-slate-200 bg-white flex-shrink-0">
        <h1 className="text-2xl md:text-3xl font-bold text-slate-800">
          Quản Lý Địa Điểm
        </h1>
        <p className="text-slate-600 text-sm md:text-base mt-1">
          Quản lý danh sách địa điểm du lịch và thông tin liên quan
        </p>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto p-4 md:p-6 lg:p-8 space-y-6">
        {/* Toolbar */}
        <div className="bg-white rounded-lg shadow-sm p-4 md:p-6 space-y-4 flex-shrink-0">
          <div className="flex flex-col sm:flex-row gap-3 items-stretch sm:items-center justify-between">
            <div className="flex-1 min-w-0">
              <div className="relative">
                <Search
                  className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 flex-shrink-0"
                  size={20}
                />
                <input
                  type="text"
                  placeholder="Tìm kiếm..."
                  className="w-full pl-10 pr-4 py-2.5 border border-slate-300 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 text-sm md:text-base"
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
              className="flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2.5 rounded-lg transition font-medium shadow-md hover:shadow-lg text-sm md:text-base flex-shrink-0 whitespace-nowrap"
            >
              <Plus size={20} />
              <span className="hidden sm:inline">Thêm Địa Điểm</span>
              <span className="sm:hidden">Thêm</span>
            </button>
          </div>

          <div className="flex flex-wrap gap-2">
            <button
              onClick={() => {
                setCategoryFilter("");
                setCurrentPage(1);
              }}
              className={`px-3 md:px-4 py-2 rounded-lg text-xs md:text-sm font-medium transition whitespace-nowrap ${
                !categoryFilter
                  ? "bg-blue-600 text-white"
                  : "bg-slate-100 text-slate-700 hover:bg-slate-200"
              }`}
            >
              Tất Cả
            </button>
            {categories.map((cat) => (
              <button
                key={cat}
                onClick={() => {
                  setCategoryFilter(cat);
                  setCurrentPage(1);
                }}
                className={`px-3 md:px-4 py-2 rounded-lg text-xs md:text-sm font-medium transition whitespace-nowrap ${
                  categoryFilter === cat
                    ? "bg-blue-600 text-white"
                    : "bg-slate-100 text-slate-700 hover:bg-slate-200"
                }`}
              >
                {cat}
              </button>
            ))}
          </div>
        </div>

        {/* Table */}
        <div className="bg-white rounded-lg shadow-sm overflow-hidden flex flex-col flex-1 min-h-0">
          <div className="overflow-x-auto flex-1">
            <table className="w-full text-sm md:text-base">
              <thead className="bg-slate-50 border-b border-slate-200 sticky top-0">
                <tr>
                  <th className="px-2 md:px-4 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Hình
                  </th>
                  <th className="px-2 md:px-4 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Tên
                  </th>
                  <th className="px-2 md:px-4 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider hidden sm:table-cell">
                    Danh Mục
                  </th>
                  <th className="px-2 md:px-4 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider hidden md:table-cell">
                    Tỉnh
                  </th>
                  <th className="px-2 md:px-4 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider hidden lg:table-cell">
                    Đánh Giá
                  </th>
                  <th className="px-2 md:px-4 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider hidden lg:table-cell">
                    Lượt Xem
                  </th>
                  <th className="px-2 md:px-4 py-3 text-center text-xs font-medium text-slate-500 uppercase tracking-wider">
                    Hành Động
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200">
                {isLoading ? (
                  <TableLoadingSpinner colSpan={7} />
                ) : displayedDestinations.length > 0 ? (
                  displayedDestinations.map((destination) => (
                    <tr
                      key={destination.id}
                      className="hover:bg-slate-50 transition text-xs md:text-sm"
                    >
                      <td className="px-2 md:px-4 py-3 whitespace-nowrap">
                        {destination.images?.length &&
                        destination.images[0]?.imageUrl ? (
                          <img
                            className="h-10 w-12 md:h-12 md:w-16 rounded object-cover"
                            src={destination.images[0]?.imageUrl}
                            alt={destination.name}
                          />
                        ) : (
                          <div className="h-10 w-12 md:h-12 md:w-16 rounded bg-slate-100 flex items-center justify-center flex-shrink-0">
                            <ImageIcon size={16} className="text-slate-400" />
                          </div>
                        )}
                      </td>
                      <td className="px-2 md:px-4 py-3 min-w-0">
                        <div>
                          <p className="font-medium text-slate-800 line-clamp-1">
                            {destination.name}
                          </p>
                          <p className="text-xs text-slate-500 line-clamp-1">
                            {destination.address}
                          </p>
                        </div>
                      </td>
                      <td className="px-2 md:px-4 py-3 whitespace-nowrap hidden sm:table-cell">
                        <span className="bg-purple-100 text-purple-700 px-2 md:px-3 py-1 rounded-full text-xs font-medium inline-block">
                          {destination.category}
                        </span>
                      </td>
                      <td className="px-2 md:px-4 py-3 whitespace-nowrap text-slate-700 hidden md:table-cell text-xs md:text-sm">
                        {destination.province.name}
                      </td>
                      <td className="px-2 md:px-4 py-3 whitespace-nowrap hidden lg:table-cell">
                        <div className="flex items-center gap-1">
                          <Star
                            size={14}
                            className="text-yellow-500 fill-yellow-500 flex-shrink-0"
                          />
                          <span className="font-medium text-slate-800">
                            {destination.averageRating}
                          </span>
                          <span className="text-xs text-slate-500">
                            ({destination.reviewCount})
                          </span>
                        </div>
                      </td>
                      <td className="px-2 md:px-4 py-3 whitespace-nowrap hidden lg:table-cell">
                        <div className="flex items-center gap-1 text-slate-700">
                          <Eye size={14} className="flex-shrink-0" />
                          <span>{destination.viewCount.toLocaleString()}</span>
                        </div>
                      </td>
                      <td className="px-2 md:px-4 py-3 whitespace-nowrap">
                        <div className="flex gap-1 justify-center flex-shrink-0">
                          <button
                            onClick={() => handleOpenModal(destination)}
                            className="p-1.5 md:p-2 bg-yellow-100 hover:bg-yellow-200 text-yellow-700 rounded transition"
                            title="Chỉnh sửa"
                          >
                            <Edit2 size={16} />
                          </button>
                          <button
                            onClick={() => handleDelete(destination.id)}
                            className="p-1.5 md:p-2 bg-red-100 hover:bg-red-200 text-red-700 rounded transition"
                            title="Xóa"
                          >
                            <Trash2 size={16} />
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
            <div className="bg-white px-4 md:px-6 py-3 border-t border-slate-200 flex items-center justify-between flex-wrap gap-3 text-xs md:text-sm flex-shrink-0">
              <div className="text-slate-600 order-3 md:order-1 w-full md:w-auto text-center md:text-left">
                <span className="font-semibold">{startIdx + 1}</span> -{" "}
                <span className="font-semibold">
                  {Math.min(
                    startIdx + itemsPerPage,
                    filteredDestinations.length
                  )}
                </span>{" "}
                /{" "}
                <span className="font-semibold">
                  {filteredDestinations.length}
                </span>
              </div>
              <div className="flex gap-1 items-center order-1 md:order-2">
                <button
                  onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                  disabled={currentPage === 1}
                  className="p-1.5 hover:bg-slate-100 disabled:opacity-50 disabled:cursor-not-allowed rounded transition"
                >
                  <ChevronLeft size={18} />
                </button>
                <span className="font-medium text-slate-700 px-2 whitespace-nowrap">
                  {currentPage} / {totalPages}
                </span>
                <button
                  onClick={() =>
                    setCurrentPage(Math.min(totalPages, currentPage + 1))
                  }
                  disabled={currentPage === totalPages}
                  className="p-1.5 hover:bg-slate-100 disabled:opacity-50 disabled:cursor-not-allowed rounded transition"
                >
                  <ChevronRight size={18} />
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-end md:items-center justify-center z-50 p-0 md:p-4 transition-opacity duration-300">
          <div className="bg-white rounded-t-2xl md:rounded-lg shadow-xl w-full md:max-w-2xl h-[100vh] md:max-h-[90vh] flex flex-col">
            {/* Modal Header */}
            <div className="flex items-center justify-between p-4 md:p-5 border-b border-slate-200 flex-shrink-0">
              <h2 className="text-lg md:text-xl font-bold text-slate-800 truncate">
                {editingId ? "Chỉnh Sửa" : "Thêm Địa Điểm"}
              </h2>
              <button
                onClick={handleCloseModal}
                className="text-slate-400 hover:text-slate-600 p-1 rounded-full hover:bg-slate-100 flex-shrink-0"
              >
                <X size={20} />
              </button>
            </div>

            {/* Modal Body */}
            <div className="p-4 md:p-6 space-y-4 overflow-y-auto flex-1">
              {/* Hàng 1: Tên & Danh Mục */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs md:text-sm font-medium text-slate-700 mb-1.5">
                    Tên Địa Điểm *
                  </label>
                  <input
                    type="text"
                    className="w-full px-3 md:px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 text-sm md:text-base"
                    value={formData.name}
                    onChange={(e) =>
                      setFormData({ ...formData, name: e.target.value })
                    }
                    placeholder="Nhập tên địa điểm"
                  />
                </div>
                <div>
                  <label className="block text-xs md:text-sm font-medium text-slate-700 mb-1.5">
                    Danh Mục
                  </label>
                  <select
                    className="w-full px-3 md:px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 bg-white text-sm md:text-base"
                    value={formData.category}
                    onChange={(e) =>
                      setFormData({ ...formData, category: e.target.value })
                    }
                  >
                    <option value="">Chọn danh mục</option>
                    {categories.map((cat) => (
                      <option key={cat} value={cat}>
                        {cat}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Hàng 2: Tỉnh Thành & Địa Chỉ */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs md:text-sm font-medium text-slate-700 mb-1.5">
                    Tỉnh Thành *
                  </label>
                  <select
                    className="w-full px-3 md:px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 bg-white text-sm md:text-base"
                    value={formData.provinceId}
                    onChange={(e) =>
                      setFormData({ ...formData, provinceId: e.target.value })
                    }
                  >
                    <option value="">Chọn tỉnh thành</option>
                    {provinces.map((p) => (
                      <option key={p.id} value={p.id}>
                        {p.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-xs md:text-sm font-medium text-slate-700 mb-1.5">
                    Địa Chỉ
                  </label>
                  <input
                    type="text"
                    className="w-full px-3 md:px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 text-sm md:text-base"
                    value={formData.address}
                    onChange={(e) =>
                      setFormData({ ...formData, address: e.target.value })
                    }
                    placeholder="Nhập địa chỉ"
                  />
                </div>
              </div>

              {/* Hàng 3: Tọa Độ */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs md:text-sm font-medium text-slate-700 mb-1.5">
                    Vĩ Độ *
                  </label>
                  <input
                    type="number"
                    step="0.000001"
                    className="w-full px-3 md:px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 text-sm md:text-base"
                    value={formData.latitude}
                    onChange={(e) =>
                      setFormData({ ...formData, latitude: e.target.value })
                    }
                    placeholder="-90 đến 90"
                  />
                </div>
                <div>
                  <label className="block text-xs md:text-sm font-medium text-slate-700 mb-1.5">
                    Kinh Độ *
                  </label>
                  <input
                    type="number"
                    step="0.000001"
                    className="w-full px-3 md:px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 text-sm md:text-base"
                    value={formData.longitude}
                    onChange={(e) =>
                      setFormData({ ...formData, longitude: e.target.value })
                    }
                    placeholder="-180 đến 180"
                  />
                </div>
              </div>

              {/* Hàng 4: Giá & Giờ Mở Cửa */}

              <div className="space-y-4">
                <label className="block text-xs md:text-sm font-medium text-slate-700">
                  Giờ Mở Cửa
                </label>

                <div className="bg-white border border-slate-200 rounded-lg overflow-hidden">
                  {[
                    { day: "monday", label: "Thứ Hai" },
                    { day: "tuesday", label: "Thứ Ba" },
                    { day: "wednesday", label: "Thứ Tư" },
                    { day: "thursday", label: "Thứ Năm" },
                    { day: "friday", label: "Thứ Sáu" },
                    { day: "saturday", label: "Thứ Bảy", highlight: true },
                    { day: "sunday", label: "Chủ Nhật", highlight: true },
                  ].map(({ day, label, highlight }) => (
                    <div
                      key={day}
                      className={`flex items-center gap-3 p-3 border-b border-slate-100 last:border-b-0 ${
                        highlight ? "bg-blue-50" : ""
                      }`}
                    >
                      <div className="w-24 text-sm font-medium text-slate-700">
                        {label}
                      </div>

                      <div className="flex-1 flex items-center gap-3">
                        <input
                          type="text"
                          placeholder="08:00"
                          className="w-24 px-3 py-2 text-sm border border-slate-300 rounded-md focus:outline-none focus:border-blue-500"
                          value={formData.openingHoursObj?.[day]?.split("-")[0]?.trim() || ""}
                          onChange={(e) => {
                            const end = formData.openingHoursObj?.[day]?.split("-")[1]?.trim() || "17:00";
                            setFormData(prev => ({
                              ...prev,
                              openingHoursObj: {
                                ...prev.openingHoursObj,
                                [day]: `${e.target.value.trim()} - ${end}`
                              }
                            }));
                          }}
                        />
                        <span className="text-slate-500">đến</span>
                        <input
                            type="text"
                            placeholder="17:00"
                            className="w-24 px-3 py-2 text-sm border border-slate-300 rounded-md focus:outline-none focus:border-blue-500"
                            value={formData.openingHoursObj?.[day]?.split("-")[1]?.trim() || ""}
                            onChange={(e) => {
                              const start = formData.openingHoursObj?.[day]?.split("-")[0]?.trim() || "08:00";
                              setFormData(prev => ({
                                ...prev,
                                openingHoursObj: {
                                  ...prev.openingHoursObj,
                                  [day]: `${start} - ${e.target.value.trim()}`
                                }
                              }));
                            }}
                          />

                        {/* Checkbox đóng cửa */}
                        <label className="flex items-center gap-1 text-xs text-slate-600">
                          <input
                            type="checkbox"
                            checked={
                              formData.openingHoursObj?.[day] === "closed"
                            }
                            onChange={(e) => {
                              setFormData((prev) => ({
                                ...prev,
                                openingHoursObj: {
                                  ...prev.openingHoursObj,
                                  [day]: e.target.checked
                                    ? "closed"
                                    : "08:00 - 17:00",
                                },
                              }));
                            }}
                          />
                          <span>Đóng cửa</span>
                        </label>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Mô Tả */}
              <div>
                <label className="block text-xs md:text-sm font-medium text-slate-700 mb-1.5">
                  Mô Tả
                </label>
                <div className="text-sm md:text-base">
                  <ReactQuill
                    theme="snow"
                    className="border border-slate-300 rounded-lg bg-white"
                    value={formData.description}
                    onChange={(html) =>
                      setFormData({ ...formData, description: html })
                    }
                    placeholder="Nhập mô tả chi tiết"
                  />
                </div>
              </div>

              {/* Upload Ảnh */}
              <div>
                <label className="block text-xs md:text-sm font-medium text-slate-700 mb-1.5">
                  Hình Ảnh
                </label>
                <div className="space-y-3">
                  <input
                    type="file"
                    id="imageInput"
                    accept="image/png, image/jpeg"
                    multiple
                    onChange={handleImageChange}
                    className="hidden"
                  />
                  <label
                    htmlFor="imageInput"
                    className="cursor-pointer inline-flex items-center gap-2 px-3 md:px-4 py-2 border border-slate-300 text-xs md:text-sm font-medium rounded-md text-slate-700 bg-white hover:bg-slate-50"
                  >
                    <Upload size={16} />
                    <span>Tải Ảnh Lên</span>
                  </label>
                  <p className="text-xs text-slate-500">
                    PNG, JPG. Tối đa 5MB mỗi ảnh.
                  </p>

                  {/* Hiển thị ảnh cũ (từ server) */}
                  {existingImages.length > 0 && (
                    <div>
                      <p className="text-xs font-medium text-slate-600 mb-2">
                        Ảnh hiện có:
                      </p>
                      <div className="grid grid-cols-3 md:grid-cols-4 gap-2">
                        {existingImages.map((img, idx) => (
                          <div
                            key={`existing-${idx}`}
                            className="relative group aspect-square"
                          >
                            <img
                              src={img.url}
                              alt={`Existing ${idx}`}
                              className="w-full h-full object-cover rounded border border-slate-300"
                            />
                            <button
                              onClick={() => handleRemoveExistingImage(idx)}
                              disabled={isDeletingImage === idx}
                              className="absolute top-1 right-1 bg-red-500 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition disabled:opacity-50"
                            >
                              {isDeletingImage === idx ? (
                                <Loader2 size={14} className="animate-spin" />
                              ) : (
                                <X size={14} />
                              )}
                            </button>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Hiển thị ảnh mới (upload) */}
                  {newImagePreviews.length > 0 && (
                    <div>
                      <p className="text-xs font-medium text-slate-600 mb-2">
                        Ảnh mới:
                      </p>
                      <div className="grid grid-cols-3 md:grid-cols-4 gap-2">
                        {newImagePreviews.map((url, idx) => (
                          <div
                            key={`new-${idx}`}
                            className="relative group aspect-square"
                          >
                            <img
                              src={url}
                              alt={`New ${idx}`}
                              className="w-full h-full object-cover rounded border-2 border-blue-300 bg-blue-50"
                            />
                            <button
                              onClick={() => handleRemoveNewImage(idx)}
                              className="absolute top-1 right-1 bg-red-500 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition"
                            >
                              <X size={14} />
                            </button>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              </div>

              {/* Checkbox Nổi Bật */}
              <div className="flex items-center gap-3 pt-2">
                <input
                  type="checkbox"
                  id="isFeatured"
                  checked={formData.isFeatured}
                  onChange={(e) =>
                    setFormData({ ...formData, isFeatured: e.target.checked })
                  }
                  className="w-4 h-4 rounded text-blue-600 focus:ring-blue-500"
                />
                <label
                  htmlFor="isFeatured"
                  className="text-xs md:text-sm font-medium text-slate-700 select-none"
                >
                  Đánh dấu là địa điểm nổi bật
                </label>
              </div>
            </div>

            {/* Modal Footer */}
            <div className="flex gap-3 p-4 md:p-5 border-t border-slate-200 bg-slate-50 rounded-b-lg flex-shrink-0">
              <button
                onClick={handleCloseModal}
                disabled={isSubmitting}
                className="flex-1 px-4 py-2.5 border border-slate-300 text-slate-700 rounded-lg hover:bg-slate-100 transition font-medium disabled:opacity-50 text-sm md:text-base"
              >
                Hủy
              </button>
              <button
                onClick={handleSubmit}
                disabled={isSubmitting}
                className="flex-1 px-4 py-2.5 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-medium disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 text-sm md:text-base"
              >
                {isSubmitting ? (
                  <>
                    <Loader2 size={18} className="animate-spin flex-shrink-0" />
                    <span>Đang lưu...</span>
                  </>
                ) : editingId ? (
                  "Cập Nhật"
                ) : (
                  "Thêm Mới"
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default DestinationManagement;
