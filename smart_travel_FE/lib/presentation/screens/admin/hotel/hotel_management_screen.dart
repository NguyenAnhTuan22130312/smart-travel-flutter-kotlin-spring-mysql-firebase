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
    _loadData();
  }

  void _loadData({int page = 0}) {
    context.read<HotelBloc>().add(
      LoadHotelsEvent(
        keyword: _searchController.text.trim(),
        sortBy: 'createdAt',
        sortDir: 'desc',
        page: page,
      ),
    );
  }

  void _showModal({Hotel? hotel}) {
    if (!_isStrictHotelAdmin()) return;
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
    if (!_isStrictHotelAdmin()) return;
    final hotelBloc = context.read<HotelBloc>();
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Icon thùng rác cảnh báo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.redAccent,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Tiêu đề to rõ
                const Text(
                  "Xác nhận xóa?",
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Nội dung chi tiết
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 15,
                      height: 1.5,
                      fontFamily: 'Roboto',
                    ),
                    children: [
                      const TextSpan(
                        text: "Bạn có chắc chắn muốn xóa khách sạn\n",
                      ),
                      TextSpan(
                        text: "\"${hotel.name}\"",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textGray,
                        ),
                      ),
                      const TextSpan(
                        text: " không?\nHành động này không thể hoàn tác.",
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 4. Khu vực nút bấm
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Hủy bỏ",
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nút Xóa (Màu đỏ cảnh báo)
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
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

  bool _isStrictHotelAdmin() {
    final authState = context.read<AuthBloc>().state;
    String? role;

    if (authState is LoginSuccess) {
      role = authState.response.role;
    } else if (authState is AdminAuthenticated) {
      role = authState.role;
    }

    // CHỈ chấp nhận ADMIN_HOTEL, loại bỏ hoàn toàn ADMIN
    return role == "ADMIN_HOTEL" || role == "ADMINHOTEL";
  }

  void _handleStrictAction(VoidCallback action) {
    if (_isStrictHotelAdmin()) {
      action(); // Nếu là ADMIN_HOTEL thì cho phép làm tiếp
    } else {
      // Nếu là ADMIN tổng hoặc USER thường, dừng lại và báo lỗi
      _showForbiddenSnackBar();
    }
  }

  void _showForbiddenSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Quyền hạn hạn chế',
          message: 'Chỉ Quản lý khách sạn mới có quyền thực hiện thao tác này!',
          contentType: ContentType.help, // Hoặc .failure
        ),
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Quản Lý Khách Sạn',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
        elevation: 0,
      ),
      body: BlocConsumer<HotelBloc, HotelState>(
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading =
              state is HotelLoading || state is DeleteHotelLoading;
          return Stack(
            children: [
              // --- NỘI DUNG CHÍNH ---
              Column(
                children: [
                  _buildHeaderActions(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            children: [
                              Expanded(child: _buildHotelTable(_currentHotels)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPagination(_totalPages),
                  const SizedBox(height: 20),
                ],
              ),

              // --- LOADING OVERLAY ---
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET: TẠO HEADER ---
  Widget _buildHeaderActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.dividerGray),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textGray),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm khách sạn...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: AppColors.menuIconGray),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (_) => _loadData(page: 0),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => _handleStrictAction(() => _showModal(hotel: null)),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Thêm Mới",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.button,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: TẠO TẠO HOTEL TABLE ---
  Widget _buildHotelTable(List<Hotel> hotels) {
    if (hotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.hotel_class_outlined,
              size: 64,
              color: AppColors.dividerGray,
            ),
            const SizedBox(height: 16),
            Text(
              "Không có dữ liệu khách sạn",
              style: TextStyle(
                color: AppColors.textGray.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  AppColors.primary.withOpacity(0.08),
                ),
                dataRowHeight: 70,
                dividerThickness: 0.5,
                horizontalMargin: 20,
                columnSpacing: 20,
                columns: [
                  _buildDataColumn('Ảnh'),
                  _buildDataColumn('ID'),
                  _buildDataColumn('Tên Khách Sạn'),
                  _buildDataColumn('Giá Sàn (VNĐ)'),
                  _buildDataColumn('Hành động', alignEnd: true),
                ],
                rows:
                    hotels.map((hotel) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.dividerGray,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child:
                                    hotel.thumbnail != null
                                        ? Image.network(
                                          hotel.thumbnail!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  size: 20,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                        )
                                        : Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.hotel,
                                            color: Colors.grey,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              "#${hotel.id}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textGray,
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 180,
                              child: Text(
                                hotel.name ?? "Chưa đặt tên",
                                style: const TextStyle(
                                  color: AppColors.textGray,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              "${hotel.minPrice?.toStringAsFixed(0) ?? 0}",
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildActionButton(
                                  icon: Icons.edit_outlined,
                                  color: AppColors.secondary,
                                  onPressed: () => _handleStrictAction(() => _showModal(hotel: hotel)),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.delete_outline,
                                  color: Colors.redAccent,
                                  onPressed: () => _handleStrictAction(() => _confirmDelete(hotel)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper để tạo cột bảng thống nhất style
  DataColumn _buildDataColumn(String label, {bool alignEnd = false}) {
    return DataColumn(
      numeric: alignEnd,
      label: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.menuIconGray,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  // Helper tạo nút hành động nhỏ gọn đẹp
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
  // --- WIDGET: TẠO PAGINATION ---
  Widget _buildPagination(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: _currentPage > 0 ? AppColors.primary : Colors.grey,
            onPressed:
                _currentPage > 0
                    ? () => _loadData(page: _currentPage - 1)
                    : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Trang ${_currentPage + 1} / $totalPages",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textGray,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color:
                _currentPage < totalPages - 1 ? AppColors.primary : Colors.grey,
            onPressed:
                _currentPage < totalPages - 1
                    ? () => _loadData(page: _currentPage + 1)
                    : null,
          ),
        ],
      ),
    );
  }
}
