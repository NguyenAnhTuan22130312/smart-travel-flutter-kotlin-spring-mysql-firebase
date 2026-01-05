import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_travel/domain/entities/voucher.dart'; // Đảm bảo đúng tên Entity
import 'package:smart_travel/presentation/blocs/admin_voucher/voucher_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_voucher/voucher_event.dart';
import 'package:smart_travel/presentation/blocs/admin_voucher/voucher_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'voucher_form_modal.dart';

class VoucherManagementScreen extends StatefulWidget {
  const VoucherManagementScreen({Key? key}) : super(key: key);

  @override
  State<VoucherManagementScreen> createState() => _VoucherManagementScreenState();
}

class _VoucherManagementScreenState extends State<VoucherManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Voucher> _allVouchers = [];
  List<Voucher> _filteredVouchers = [];

  @override
  void initState() {
    super.initState();
    // Không cần add(LoadAllVoucher) ở đây nữa vì đã làm bên AppRouter
  }

  void _filterVouchers(String query) {
    if (query.isEmpty) {
      setState(() => _filteredVouchers = _allVouchers);
    } else {
      setState(() {
        _filteredVouchers = _allVouchers
            .where((v) => v.code.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  // --- SỬA LỖI POPUP KHÔNG NHẬN BLOC ---
  void _showModal({Voucher? voucher}) {
    // 1. Lấy Bloc hiện tại từ màn hình cha
    final bloc = context.read<VoucherBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        // 2. Truyền Bloc vào trong Dialog thông qua .value
        value: bloc,
        child: VoucherFormModal(
          voucher: voucher,
          onReset: () {},
        ),
      ),
    );
  }

  // --- SỬA LỖI XÓA KHÔNG ĐƯỢC ---
  void _deleteVoucher(Voucher voucher) {
    // 1. Lấy Bloc hiện tại trước khi mở Dialog
    final bloc = context.read<VoucherBloc>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa mã '${voucher.code}' không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              // 2. Sử dụng biến bloc đã lấy ở trên để add Event
              bloc.add(DeleteVoucherEvent(voucher.id));
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String title, String message, ContentType type) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    // --- KHÔNG BỌC BlocProvider Ở ĐÂY NỮA ---
    // Vì AppRouter đã cung cấp rồi.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Khuyến Mãi"),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textGray,
      ),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showModal(), // Gọi hàm mở modal thêm mới
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
      body: BlocListener<VoucherBloc, VoucherState>(
        listener: (context, state) {
          if (state is VoucherActionSuccess) {
            _showSnackBar("Thành công", state.message, ContentType.success);
            // Sau khi thêm/sửa/xóa thành công, Bloc tự load lại list, state sẽ chuyển sang DataLoaded
          } else if (state is VoucherActionError) {
            _showSnackBar("Lỗi", state.message, ContentType.failure);
          } else if (state is VoucherDataLoaded) {
            setState(() {
              _allVouchers = state.vouchers;
              _filteredVouchers = state.vouchers;
            });
          }
        },
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterVouchers,
                decoration: InputDecoration(
                  hintText: "Tìm kiếm theo mã code...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),

            // List Data
            Expanded(
              child: BlocBuilder<VoucherBloc, VoucherState>(
                buildWhen: (previous, current) =>
                current is VoucherDataLoaded || current is VoucherDataLoading,
                builder: (context, state) {
                  if (state is VoucherDataLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Nếu danh sách rỗng
                  if (_filteredVouchers.isEmpty) {
                    // Nếu đang load lần đầu chưa có data
                    if (state is VoucherInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.discount_outlined, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text("Chưa có voucher nào", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  final formatter = NumberFormat("#,###");

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _filteredVouchers.length,
                    itemBuilder: (context, index) {
                      final voucher = _filteredVouchers[index];
                      final isExpired = voucher.expiryDate.isBefore(DateTime.now());

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: voucher.isActive
                                  ? (isExpired ? Colors.grey.shade200 : Colors.pink.shade50)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.local_offer,
                              color: voucher.isActive
                                  ? (isExpired ? Colors.grey : Colors.pink)
                                  : Colors.grey,
                            ),
                          ),
                          title: Text(
                            voucher.code,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                "Giảm: ${formatter.format(voucher.discountAmount)} VND",
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "HSD: ${DateFormat('dd/MM/yyyy').format(voucher.expiryDate)} ${isExpired ? '(Hết hạn)' : ''}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isExpired ? Colors.red : Colors.grey.shade600,
                                ),
                              ),
                              Text("Số lượng: ${voucher.usageLimit}", style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showModal(voucher: voucher),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteVoucher(voucher),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}