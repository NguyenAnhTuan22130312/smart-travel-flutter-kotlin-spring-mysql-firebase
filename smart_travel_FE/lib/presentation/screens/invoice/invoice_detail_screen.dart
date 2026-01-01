import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/injection_container.dart' as di;
import 'package:smart_travel/presentation/blocs/invoice/detail_bloc.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import '../../../router/route_names.dart';
import 'cancel_booking_screen.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final int bookingId;

  const InvoiceDetailScreen({Key? key, required this.bookingId})
    : super(key: key);

  String _formatDate(String date) {
    List<String> parts = date.split('-');
    return "${parts[2]}/${parts[1]}/${parts[0]}";
  }

  String _formatPrice(double price) {
    return price
            .toStringAsFixed(0)
            .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]}.',
            ) +
        ' ₫';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return AppColors.primary;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELED':
        return Colors.red;
      case 'PENDING_REFUND':
        return Colors.orange;
      case 'REFUNDED':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'ACTIVE':
        return "Đang hoạt động";
      case 'COMPLETED':
        return "Đã hoàn thành";
      case 'CANCELED':
        return "Đã hủy";
      case 'PENDING_REFUND':
        return "Đang chờ hoàn tiền";
      case 'REFUNDED':
        return "Đã hoàn tiền";
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[50],
      body: BlocProvider(
        create: (_) => di.sl<DetailBloc>()..add(LoadInvoiceDetail(bookingId)),
        child: BlocBuilder<DetailBloc, DetailState>(
          builder: (context, state) {
            if (state is DetailLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is DetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Không thể tải chi tiết đơn hàng",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed:
                          () => context.read<DetailBloc>().add(
                            LoadInvoiceDetail(bookingId),
                          ),
                      child: const Text("Thử lại"),
                    ),
                  ],
                ),
              );
            }

            if (state is DetailLoaded) {
              final detail = state.detail;

              final bool canCancel = detail.status == "ACTIVE";
              return CustomScrollView(
                slivers: [
                  // AppBar với ảnh + tên hotel/tour
                  SliverAppBar(
                    expandedHeight: 300,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.white,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Ảnh thumbnail – sửa loading/error để không xám
                          Image.network(
                            detail.thumbnailUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(
                                    detail.bookingType == "HOTEL"
                                        ? Icons.hotel
                                        : Icons.tour,
                                    size: 80,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                          ),
                          // Overlay tối dưới
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                              ),
                            ),
                          ),
                          // Nút back
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 10,
                            left: 16,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          // Khung trắng chứa tên + nút "Chi tiết"
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                20,
                                16,
                                20,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Tên hotel/tour - cắt ngắn nếu dài
                                  Expanded(
                                    child: Text(
                                      detail.serviceName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Nút "Chi tiết" - cố định bên phải, màu xanh dương nhẹ
                                  GestureDetector(
                                    onTap: () {
                                      if (detail.hotelId != null) {
                                        Navigator.pushNamed(
                                          context,
                                          RouteNames.hotelDetail,
                                          arguments: detail.hotelId,
                                        );
                                      } else if (detail.tourId != null) {
                                        Navigator.pushNamed(
                                          context,
                                          RouteNames.tourDetail,
                                          arguments: detail.tourId,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Không có thông tin chi tiết để xem",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "Chi tiết",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary
                                                .withOpacity(0.9),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: AppColors.primary.withOpacity(
                                            0.9,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // === KHÁCH HÀNG + MÃ ĐẶT CHỖ ===
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail.customerName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Mã đặt chỗ: ${detail.invoiceNumber}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "SĐT: ${detail.customerPhone}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Email: ${detail.customerEmail}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // === THÔNG TIN PHÒNG / TOUR ===
                          if (detail.roomTypeName != null ||
                              detail.roomAmenities.isNotEmpty ||
                              detail.bookingType == "TOUR")
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
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
                              child: Table(
                                columnWidths: const {
                                  0: IntrinsicColumnWidth(),
                                  // Cột trái tự động vừa tiêu đề
                                  1: FlexColumnWidth(),
                                  // Cột phải chiếm hết không gian còn lại
                                },
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.top,
                                children: [
                                  // Hàng 1: Thông tin phòng + Tên phòng
                                  TableRow(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 16),
                                        child: Text(
                                          "Thông tin phòng:",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        child: Text(
                                          detail.roomTypeName ??
                                              (detail.bookingType == "TOUR"
                                                  ? "Tour trọn gói"
                                                  : "Không có thông tin"),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.end,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Hàng 2: Tiện nghi + Danh sách
                                  TableRow(
                                    children: [
                                      const Text(
                                        "Tiện nghi:",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      if (detail.roomAmenities.isNotEmpty)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children:
                                              detail.roomAmenities.map((
                                                amenity,
                                              ) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 6,
                                                      ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        "• ",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                      ),
                                                      Flexible(
                                                        child: Text(
                                                          amenity.trim(),
                                                          style: const TextStyle(
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                          textAlign:
                                                              TextAlign.end,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                        )
                                      else
                                        const Text(
                                          "Không có tiện ích",
                                          style: TextStyle(fontSize: 15, color: Colors.grey),
                                          textAlign: TextAlign.end,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),

                          // === YÊU CẦU ĐẶC BIỆT ===
                          if (detail.specialRequests != null &&
                              detail.specialRequests!.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Yêu cầu đặc biệt",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    detail.specialRequests!,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          if (detail.specialRequests != null &&
                              detail.specialRequests!.isNotEmpty)
                            const SizedBox(height: 10),

                          // === NGÀY NHẬN/TRẢ PHÒNG - ĐẸP NHƯ TRAVELOKA ===
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Nhận phòng",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(detail.startDate),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            "14:00",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Icon(
                                          Icons.nights_stay,
                                          color: AppColors.primary,
                                          size: 32,
                                        ),
                                        Text(
                                          "${detail.nights} đêm",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Trả phòng",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(detail.endDate),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            "12:00",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // === CHI TIẾT THANH TOÁN ===
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Chi tiết thanh toán",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Tổng tiền"),
                                    Text(_formatPrice(detail.totalPrice)),
                                  ],
                                ),
                                if (detail.discountAmount > 0) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Giảm giá"),
                                      Text(
                                        "- ${_formatPrice(detail.discountAmount)}",
                                        style: const TextStyle(
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Thành tiền",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _formatPrice(detail.finalPrice),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // === NÚT HÀNH ĐỘNG ===
                          Row(
                            children: [
                              if (canCancel)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => CancelBookingScreen(
                                                bookingData: {
                                                  'bookingId': detail.bookingId,
                                                  'invoiceNumber':
                                                      detail.invoiceNumber,
                                                  'itemName':
                                                      detail.serviceName,
                                                  'startDate': detail.startDate,
                                                  'endDate': detail.endDate,
                                                  'nights': detail.nights,
                                                },
                                              ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                      foregroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: const Text(
                                      "Hủy đặt chỗ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              if (canCancel) const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Xuất phiếu
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text(
                                    "Xuất phiếu thanh toán",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          },
        ),
      ),
    );
  }
}
