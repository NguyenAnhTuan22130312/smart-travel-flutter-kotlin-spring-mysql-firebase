import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotail_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_event.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_state.dart';
import 'package:smart_travel/presentation/screens/admin/hotel/hotel_form_dialog.dart';

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
    //  BƯỚC 1: "Bắt" lấy cái Bloc đang hoạt động ở màn hình này trước khi mở Dialog
    final hotelBloc = context.read<HotelBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Xóa khách sạn '${hotel.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // Đóng dialog dùng context của dialog
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Đóng dialog trước
              Navigator.pop(dialogContext);

              // BƯỚC 2: Dùng biến hotelBloc đã lấy ở trên để add event.
              hotelBloc.add(
                DeleteHotelEvent(hotelId: hotel.id!),
              );
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Quản Lý Khách Sạn')),
      body: BlocConsumer<HotelBloc, HotelState>(
        listener: (context, state) {
          if (state is HotelLoaded) {
            // 1. Cập nhật dữ liệu khi load xong
            _currentHotels = state.hotels;
            _currentPage = state.currentPage;
            _totalPages = state.totalPages;
          }
          // 2. Hiện thông báo thành công
          if (state is HotelOperationSuccess) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          // 3. Hiện lỗi
          if (state is HotelError || state is DeleteHotelError) {
            // Lấy message lỗi tùy state
            String msg = state is HotelError ? state.message : (state as DeleteHotelError).message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red),
            );
          }
        },

        builder: (context, state) {
          final bool isLoading = state is HotelLoading || state is DeleteHotelLoading;
          return Stack(
            children: [
              // --- LỚP DƯỚI: NỘI DUNG ---
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buildHotelTable(_currentHotels),
                  ),
                  _buildPagination(_totalPages),
                  const SizedBox(height: 10),
                ],
              ),

              // --- LỚP TRÊN: LOADING OVERLAY ---
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _loadData(page: 0),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () => _showModal(hotel: null),
          icon: const Icon(Icons.add),
          label: const Text("Thêm"),
        ),
      ],
    );
  }

  Widget _buildHotelTable(List<Hotel> hotels) {
    if (hotels.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("Không có dữ liệu"),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Ảnh')),
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Tên')),
          DataColumn(label: Text('Giá')),
          DataColumn(label: Text('Hành động')),
        ],
        rows:
        hotels.map((hotel) {
          return DataRow(
            cells: [
              DataCell(
                hotel.thumbnail != null
                    ? Image.network(
                  hotel.thumbnail!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const Icon(Icons.broken_image),
                )
                    : const Icon(Icons.hotel),
              ),
              DataCell(Text("${hotel.id}")),
              DataCell(
                SizedBox(
                  width: 120,
                  child: Text(
                    hotel.name ?? "",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text("${hotel.minPrice?.toStringAsFixed(0) ?? 0}")),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showModal(hotel: hotel),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(hotel),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    // Ẩn phân trang nếu không có trang nào
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed:
          _currentPage > 0 ? () => _loadData(page: _currentPage - 1) : null,
        ),
        Text("Trang ${_currentPage + 1} / $totalPages"),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed:
          _currentPage < totalPages - 1
              ? () => _loadData(page: _currentPage + 1)
              : null,
        ),
      ],
    );
  }
}