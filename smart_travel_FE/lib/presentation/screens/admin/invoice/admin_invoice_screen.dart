import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/injection_container.dart' as di;
import 'package:smart_travel/presentation/blocs/admin_invoice/admin_invoice_bloc.dart';
import 'package:smart_travel/presentation/screens/admin/invoice/qr_scanner_screen.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/presentation/widgets/invoice/admin_invoice_card.dart';

import 'admin_invoice_detail_screen.dart';

class AdminInvoiceScreen extends StatefulWidget {
  const AdminInvoiceScreen({Key? key}) : super(key: key);

  @override
  State<AdminInvoiceScreen> createState() => _AdminInvoiceScreenState();
}

class _AdminInvoiceScreenState extends State<AdminInvoiceScreen> {
  String? selectedStatus;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInvoices();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadInvoices() {
    context.read<AdminInvoiceBloc>().add(
      LoadAdminInvoices(
        status: selectedStatus,
        invoiceNumber: _searchController.text,
      ),
    );
  }

  void _onSearchChanged() {
    _loadInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // === HEADER ===
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 10,
              16,
              16,
            ),
            color: AppColors.primary,
            child: Row(
              children: [
                GestureDetector(
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
                const Expanded(
                  child: Text(
                    "Quản lý đơn hàng",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 40), // Cân đối
              ],
            ),
          ),

          // === SEARCH + ICON QR ===
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Tìm mã đơn hàng...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () async {
                    final bookingId = await Navigator.push<int>(
                      context,
                      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
                    );

                    if (bookingId != null && mounted) {
                      // Mở chi tiết, nhưng nếu lỗi thì Bloc sẽ xử lý
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminInvoiceDetailScreen(bookingId: bookingId),
                        ),
                      );
                    }
                  },
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // === FILTER STATUS ===
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(null, "Tất cả"),
                _buildFilterChip("ACTIVE", "Đang hoạt động"),
                _buildFilterChip("CHECKED", "Đã nhận phòng"),
                _buildFilterChip("COMPLETED", "Đã hoàn thành"),
                _buildFilterChip("PENDING_REFUND", "Chờ hoàn tiền"),
                _buildFilterChip("REFUNDED", "Đã hoàn tiền"),
                _buildFilterChip("CANCELED", "Đã hủy"),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // === LIST CARD ===
          Expanded(
            child: BlocBuilder<AdminInvoiceBloc, AdminInvoiceState>(
              builder: (context, state) {
                Widget body;

                if (state is AdminInvoiceLoading) {
                  body = const Center(child: CircularProgressIndicator(color: AppColors.primary));
                } else if (state is AdminInvoiceError) {
                  body = Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadInvoices,
                          child: const Text("Thử lại"),
                        ),
                      ],
                    ),
                  );
                } else if (state is AdminInvoiceLoaded) {
                  if (state.invoices.isEmpty) {
                    body = const Center(child: Text("Không có đơn hàng nào"));
                  } else {
                    body = ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.invoices.length,
                      itemBuilder: (context, index) {
                        final invoice = state.invoices[index];
                        return AdminInvoiceCard(
                          bookingId: invoice.bookingId,
                          invoiceNumber: invoice.invoiceNumber,
                          itemName: invoice.itemName,
                          startDate: invoice.startDate,
                          endDate: invoice.endDate,
                          status: invoice.status,
                          onViewDetail: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminInvoiceDetailScreen(
                                  bookingId: invoice.bookingId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                } else {
                  body = const SizedBox();
                }

                // BỌC RefreshIndicator ĐỂ PULL TO REFRESH
                return RefreshIndicator(
                  onRefresh: () async {
                    _loadInvoices();
                    // Đợi Bloc xử lý xong (có thể thêm Completer nếu cần)
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  color: AppColors.primary,
                  child: body,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String? value, String label) {
    final isSelected = selectedStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedStatus = selected ? value : null;
          });
          _loadInvoices();
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        backgroundColor: Colors.grey[100],
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}