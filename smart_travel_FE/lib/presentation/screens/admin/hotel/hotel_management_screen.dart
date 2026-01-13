import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/presentation/blocs/auth/auth_bloc.dart';
import 'package:smart_travel/presentation/blocs/auth/auth_state.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_event.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_state.dart';
import 'package:smart_travel/presentation/screens/admin/hotel/hotel_form_dialog.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

class HotelManagementScreen extends StatefulWidget {
  const HotelManagementScreen({Key? key}) : super(key: key);

  @override
  State<HotelManagementScreen> createState() => _HotelManagementScreenState();
}

class _HotelManagementScreenState extends State<HotelManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Hotel> _currentHotels = [];
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    // 1. Chỉ load data nếu đúng quyền ADMINHOTEL
    if (_isHotelAdmin()) {
      _loadData();
    }
  }

  // --- HÀM CHECK QUYỀN (Logic cốt lõi) ---
  bool _isHotelAdmin() {
    final authState = context.read<AuthBloc>().state;
    String? role;
    if (authState is LoginSuccess) {
      role = authState.response.role;
    } else if (authState is AdminAuthenticated) {
      role = authState.role;
    }
    // Chỉ trả về true nếu là ADMINHOTEL
    return role == "ADMINHOTEL";
  }

  void _handleStrictAction(VoidCallback action) {
    if (_isHotelAdmin()) {
      action();
    } else {
      _showAccessDeniedSnackBar();
    }
  }

  void _showAccessDeniedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Từ chối truy cập',
          message: 'Chức năng này chỉ dành cho Quản lý Khách sạn!',
          contentType: ContentType.warning,
        ),
      ),
    );
  }

  void _loadData({int page = 0}) {
    context.read<HotelBloc>().add(
      LoadHotelsEvent(
        keyword: _searchController.text.trim(),
        sortBy: 'id',
        sortDir: 'asc',
        page: page,
      ),
    );
  }

  // Hàm helper để format tiền tệ (Ví dụ: 2500000 -> 2.500.000)
  String _formatCurrency(num amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _showModal({Hotel? hotel}) {
    if (!_isHotelAdmin()) return;
    final hotelBloc = context.read<HotelBloc>();
    final hotelDetailBloc = context.read<HotelDetailBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: hotelBloc),
            BlocProvider.value(value: hotelDetailBloc),
          ],
          child: HotelFormDialog(hotel: hotel),
        );
      },
    );
  }

  void _confirmDelete(Hotel hotel) {
    if (!_isHotelAdmin()) return;
    final hotelBloc = context.read<HotelBloc>();
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.redAccent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Xác nhận xóa?",
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      height: 1.5,
                      fontFamily: 'Roboto',
                    ),
                    children: [
                      const TextSpan(text: "Bạn có chắc chắn muốn xóa\n"),
                      TextSpan(
                        text: "\"${hotel.name}\"",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textGray,
                        ),
                      ),
                      const TextSpan(text: " không?"),
                    ],
                  ),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: AppColors.textGray,
                      ),
                      child: const Text("Hủy bỏ"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        hotelBloc.add(DeleteHotelEvent(hotelId: hotel.id!));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Xóa ngay",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 2. Check quyền ngay khi build
    final bool isHotelAdmin = _isHotelAdmin();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Màu nền sáng hiện đại
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(), // Hàm quay lại
        ),
        title: const Text(
          'Quản Lý Khách Sạn',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
        elevation: 0,
        actions: [
          // Chỉ hiện nút Thêm nếu đúng quyền
          if (isHotelAdmin)
            IconButton(
              onPressed:
                  () => _handleStrictAction(() => _showModal(hotel: null)),
              icon: const Icon(Icons.add_card, color: Colors.white, size: 26),
              tooltip: "Thêm khách sạn",
            ),
        ],
      ),
      // 3. Logic hiển thị Body
      body:
          !isHotelAdmin
              ? _buildAccessDeniedView() // Nếu ko phải ADMINHOTEL -> Chặn
              : BlocConsumer<HotelBloc, HotelState>(
                listener: (context, state) {
                  if (state is HotelLoaded) {
                    _currentHotels = state.hotels;
                    _currentPage = state.currentPage;
                    _totalPages = state.totalPages;
                  }
                  if (state is HotelOperationSuccess) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  if (state is HotelError || state is DeleteHotelError) {
                    String msg =
                        state is HotelError
                            ? state.message
                            : (state as DeleteHotelError).message;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final bool isLoading =
                      state is HotelLoading || state is DeleteHotelLoading;
                  return Stack(
                    children: [
                      Column(
                        children: [
                          _buildSearchBar(),
                          Expanded(child: _buildHotelList(_currentHotels)),
                          if (_totalPages > 1) ...[
                            _buildPagination(_totalPages),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                      if (isLoading)
                        Container(
                          color: Colors.black.withOpacity(0.2),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
    );
  }

  // --- Widget: Màn hình chặn truy cập ---
  Widget _buildAccessDeniedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.gpp_bad_rounded,
              size: 80,
              color: Colors.red[300],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Hạn chế truy cập",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Bạn không có quyền quản lý khách sạn. Vui lòng liên hệ Admin để được hỗ trợ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. SEARCH BAR (Floating Style) ---
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF909090).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: AppColors.textGray,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm tên, địa điểm...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _loadData(page: 0);
                    },
                  )
                  : null,
        ),
        onSubmitted: (_) => _loadData(page: 0),
      ),
    );
  }

  // --- 2. LIST VIEW ---
  Widget _buildHotelList(List<Hotel> hotels) {
    if (hotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.travel_explore,
                size: 60,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Chưa tìm thấy khách sạn nào",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: hotels.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildHotelCard(hotels[index]);
      },
    );
  }

  // --- 3. ITEM CARD (PREMIUM STYLE) ---
  Widget _buildHotelCard(Hotel hotel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withOpacity(0.06),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _handleStrictAction(() => _showModal(hotel: hotel)),
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primary.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3.1. Hình ảnh
                Stack(
                  children: [
                    Hero(
                      tag: 'hotel_img_${hotel.id}',
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child:
                              hotel.thumbnail != null
                                  ? Image.network(
                                    hotel.thumbnail!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Container(
                                          color: Colors.grey[100],
                                          child: const Icon(
                                            Icons.broken_image_rounded,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  )
                                  : Container(
                                    color: Colors.blue[50],
                                    child: const Icon(
                                      Icons.apartment_rounded,
                                      color: AppColors.primary,
                                      size: 30,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    // Badge ID nhỏ ở góc ảnh
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "#${hotel.id}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // 3.2. Nội dung chính
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hàng 1: Tên + Icon Star
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              hotel.name ?? "Tên chưa cập nhật",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2D3748),
                                height: 1.2,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (hotel.starRating != null) ...[
                            // Chỉ hiện nếu có rating
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "${hotel.starRating}", // Ví dụ: 4.5
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[800],
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Hàng 2: Giả lập địa chỉ (để layout đỡ trống)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Việt Nam",
                            // Placeholder vì model chưa có field address
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Hàng 3: Giá tiền
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${_formatCurrency(hotel.minPrice ?? 0)} VNĐ",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3.3. Cột thao tác
                const SizedBox(width: 8),
                Column(
                  children: [
                    _buildActionButton(
                      icon: Icons.edit_rounded,
                      color: const Color(0xFF3B82F6), // Blue 500
                      bgColor: const Color(0xFFEFF6FF), // Blue 50
                      onTap:
                          () => _handleStrictAction(
                            () => _showModal(hotel: hotel),
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      icon: Icons.delete_rounded,
                      color: const Color(0xFFEF4444), // Red 500
                      bgColor: const Color(0xFFFEF2F2), // Red 50
                      onTap:
                          () =>
                              _handleStrictAction(() => _confirmDelete(hotel)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget con: Nút hành động
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  // --- 4. PAGINATION ---
  Widget _buildPagination(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPageBtn(
            icon: Icons.chevron_left_rounded,
            isEnabled: _currentPage > 0,
            onTap: () => _loadData(page: _currentPage - 1),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Trang ${_currentPage + 1} / $totalPages",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textGray,
                fontSize: 15,
              ),
            ),
          ),

          _buildPageBtn(
            icon: Icons.chevron_right_rounded,
            isEnabled: _currentPage < totalPages - 1,
            onTap: () => _loadData(page: _currentPage + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildPageBtn({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(50),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey[100],
          shape: BoxShape.circle,
          boxShadow:
              isEnabled
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Icon(
          icon,
          size: 24,
          color: isEnabled ? AppColors.primary : Colors.grey[400],
        ),
      ),
    );
  }
}
