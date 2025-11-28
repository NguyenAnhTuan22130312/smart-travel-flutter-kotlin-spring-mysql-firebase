import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_event.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_state.dart';
import 'package:smart_travel/router/route_names.dart';
import '../../theme/app_colors.dart';

class HotelListScreen extends StatefulWidget {
  const HotelListScreen({Key? key}) : super(key: key);

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedFilter = "popular";

  // --- KHAI BÁO MÀU SẮC (CẤU HÌNH UI) ---
  static const Color textDark = Color(0xFF1F2937);
  static const Color primary = Color(0xFF2196F3);
  static const Color button = Color(0xFF23A39B);

  @override
  void initState() {
    super.initState();
    _applyFilter();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // HÀM HỖ TRỢ: Lấy sortBy/sortDir
  String _getSortBy() {
    switch (_selectedFilter) {
      case 'price_asc': return 'pricePerNight';
      case 'price_desc': return 'pricePerNight';
      case 'name_asc': return 'name';
      case 'name_desc': return 'name';
      default: return 'starRating';
    }
  }

  String _getSortDir() {
    switch (_selectedFilter) {
      case 'price_desc':
      case 'name_desc':
        return 'desc';
      case 'popular':
      default:
        return 'asc';
    }
  }

  void _applyFilter({int page = 0}) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    context.read<HotelBloc>().add(
      LoadHotelsEvent(
        keyword: _searchController.text.trim(),
        sortBy: _getSortBy(),
        sortDir: _getSortDir(),
        page: page, // Load đúng trang được chọn
      ),
    );
  }
  // --- HÀM MỚI: UI THANH PHÂN TRANG (1 2 3...) ---
  Widget _buildPaginationControls(int currentPage, int totalPages) {
    // Nếu chỉ có 1 trang hoặc không có trang nào thì không hiện
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nút Previous (<)
          IconButton(
            onPressed: currentPage > 0
                ? () => _applyFilter(page: currentPage - 1)
                : null,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: 18,
              color: currentPage > 0 ? primary : Colors.grey[300],
            ),
          ),

          // Danh sách số trang
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(totalPages, (index) {
                final isSelected = index == currentPage;
                // Hiển thị số trang (index bắt đầu từ 0 nên text hiển thị +1)
                return GestureDetector(
                  onTap: () {
                    if (!isSelected) _applyFilter(page: index);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? primary : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? primary : Colors.grey.shade300,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: primary.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: isSelected ? Colors.white : textDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Nút Next (>)
          IconButton(
            onPressed: currentPage < totalPages - 1
                ? () => _applyFilter(page: currentPage + 1)
                : null,
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: currentPage < totalPages - 1 ? primary : Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM HỖ TRỢ HIỂN THỊ TÊN LỌC ---
  String _getFilterLabel(String filterValue) {
    switch (filterValue) {
      case "popular":
        return "Phổ biến nhất";
      case "price_asc":
        return "Giá tăng dần";
      case "price_desc":
        return "Giá giảm dần";
      case "name_asc":
        return "Tên A-Z";
      case "name_desc":
        return "Tên Z-A";
      default:
        return "Sắp xếp";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, button],
              begin: Alignment.topLeft, // Bắt đầu từ góc trên bên trái
              end: Alignment.bottomRight, // Kết thúc ở góc dưới bên phải
            ),
          ),
        ),

        // Các thuộc tính UI khác của AppBar vẫn giữ nguyên
        foregroundColor: Colors.white,
        title: const Text(
          "Danh sách khách sạn",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,

        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: textDark, size: 24),
          ),
        ),
      ),

      body: Column(
        children: [
          // Giao diện Tìm kiếm và Lọc
          _buildSearchAndFilter(),
          Expanded(
            child: BlocBuilder<HotelBloc, HotelState>(
              builder: (context, state) {
                // 1. Đang tải
                if (state is HotelLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Tải xong
                if (state is HotelLoaded) {
                  final hotels = state.hotels;

                  if (hotels.isEmpty) {
                    return const Center(
                      child: Text(
                        "Không tìm thấy khách sạn nào",
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    // +1 item cho thanh phân trang
                    itemCount: hotels.length + 1,
                    itemBuilder: (context, index) {
                      // Item cuối cùng -> Render nút phân trang
                      if (index == hotels.length) {
                        return _buildPaginationControls(state.currentPage, state.totalPages);
                      }
                      // Item thường -> Render khách sạn
                      return _buildHotelCard(hotels[index]);
                    },
                  );
                }
                if (state is HotelError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Lỗi tải dữ liệu: ${state.message}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                return const Center(child: Text("Bắt đầu tìm kiếm khách sạn"));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Tìm kiếm theo tên, địa chỉ...",
              hintStyle: TextStyle(color: AppColors.textGray, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: primary, size: 20),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.textGray,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilter();
                        },
                      )
                      : null,
              border: InputBorder.none,
              filled: true,
              fillColor: AppColors.background,
              // Giảm vertical padding trong content
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primary, width: 1.5),
              ),
            ),
            onSubmitted: (value) => _applyFilter(),
          ),

          const SizedBox(height: 12), // Giữ khoảng cách vừa phải
          // 2. Filter Bar (Nút Sắp xếp duy nhất)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showSortModal(context),
                child: Container(
                  // Giảm padding để nút nhỏ gọn hơn
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getFilterEmoji(_selectedFilter),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getFilterLabel(_selectedFilter),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HÀM HỖ TRỢ: HIỂN THỊ EMOJI ---
  String _getFilterEmoji(String filterValue) {
    switch (filterValue) {
      case "popular":
        return "🔥";
      case "price_asc":
        return "💰";
      case "price_desc":
        return "⬇️";
      case "name_asc":
      case "name_desc":
        return "🔠";
      default:
        return "";
    }
  }

  // --- HÀM HỖ TRỢ: HIỂN THỊ MODAL CHỌN LỌC ---
  void _showSortModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final List<Map<String, String>> sortOptions = [
          {"value": "popular", "label": "🔥 Phổ biến nhất"},
          {"value": "price_asc", "label": "💰 Giá tăng dần"},
          {"value": "price_desc", "label": "⬇️ Giá giảm dần"},
          {"value": "name_asc", "label": "🔠 Tên A-Z"},
          {"value": "name_desc", "label": "🔠 Tên Z-A"},
        ];

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sắp xếp theo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 10),

              ...sortOptions.map((option) {
                final isSelected = _selectedFilter == option["value"];
                return ListTile(
                  title: Text(
                    option["label"]!,
                    style: TextStyle(
                      color: isSelected ? primary : textDark,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing:
                      isSelected
                          ? Icon(Icons.check_circle, color: primary)
                          : null,
                  onTap: () {
                    setState(() {
                      _selectedFilter = option["value"]!;
                      _applyFilter();
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // --- HOTEL ITEM (Cải tiến bố cục giá và địa chỉ) ---
  Widget _buildHotelCard(Hotel hotel) {
    final price =
        hotel.minPrice != null
            ? "${hotel.minPrice!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ"
            : "Liên hệ";

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          RouteNames.hotelDetail,
          arguments: hotel.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ảnh lớn (Header)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                hotel.thumbnail ?? "",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
                errorBuilder:
                    (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.hotel_rounded,
                          size: 40,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
              ),
            ),

            // 2. Nội dung chi tiết
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên khách sạn
                  Text(
                    hotel.name ?? "Tên Khách Sạn Không Xác Định",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // ĐỊA CHỈ & GIÁ (đặt trong Row để căn chỉnh tốt hơn)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Thông tin Đánh giá & Địa chỉ (Cột 1)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rating và Stars
                            Row(
                              children: [
                                // Stars
                                Row(
                                  children: List.generate(
                                    hotel.starRating ?? 0,
                                    (i) => const Icon(
                                      Icons.star_rounded,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Rating Score
                                if (hotel.averageRating != null &&
                                    hotel.averageRating! > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      hotel.averageRating!.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${hotel.reviewCount ?? 0} đánh giá)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGray,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Địa chỉ
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: AppColors.textGray,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    hotel.address ?? "Không có địa chỉ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textGray,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Giá (Cột 2)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Giá từ",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGray,
                            ),
                          ),
                          Text(
                            price,
                            style: TextStyle(
                              fontSize: 18, // Giảm cỡ chữ một chút để cân đối
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            "/ đêm",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
