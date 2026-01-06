import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart'; // Để catch DioException
import 'package:smart_travel/core/network/dio_client.dart'; // Import DioClient
import 'package:smart_travel/domain/entities/voucher.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/injection_container.dart' as di; // Import Dependency Injection

class VoucherSelectionModal extends StatefulWidget {
  final int userId;

  const VoucherSelectionModal({Key? key, required this.userId}) : super(key: key);

  @override
  State<VoucherSelectionModal> createState() => _VoucherSelectionModalState();
}

class _VoucherSelectionModalState extends State<VoucherSelectionModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // SỬA 1: Lấy DioClient từ Injection (đã có sẵn Token)
  final DioClient _dioClient = di.sl<DioClient>();

  // Không cần hardcode IP nữa vì DioClient đã config BaseURL
  // final String _baseUrl = 'http://10.0.2.2:8080/api/v1';

  List<dynamic> _myVouchers = [];
  List<dynamic> _redeemableVouchers = [];
  int _currentPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    print("----------- BẮT ĐẦU LOAD DATA MODAL -----------");
    setState(() => _isLoading = true);

    try {
      // --- GIAI ĐOẠN 1: LẤY DANH SÁCH VOUCHER (QUAN TRỌNG) ---

      // 1. Lấy voucher của tôi
      print("Step 1: Gọi API My Vouchers...");
      final myVouchersRes = await _dioClient.get(
        '/rewards/my-vouchers?userId=${widget.userId}',
      );

      // 2. Lấy voucher có thể đổi
      print("Step 2: Gọi API Available Rewards...");
      final availableRes = await _dioClient.get('/rewards/available');

      // --- HIỂN THỊ DỮ LIỆU NGAY LẬP TỨC ---
      if (mounted) {
        setState(() {
          _myVouchers = (myVouchersRes.data is List) ? myVouchersRes.data : [];
          _redeemableVouchers = (availableRes.data is List) ? availableRes.data : [];
          _isLoading = false; // Tắt loading ngay để hiện popup
        });
      }

      // --- GIAI ĐOẠN 2: LẤY ĐIỂM (KHÔNG QUAN TRỌNG, CHẠY SAU) ---
      // ... đoạn trên giữ nguyên

      // --- GIAI ĐOẠN 2: LẤY ĐIỂM ---
      print("Step 3: Gọi API User Profile (Lấy điểm)...");
      try {
        final profileRes = await _dioClient.get('/users/user/${widget.userId}');

        // IN RA ĐỂ KIỂM TRA CẤU TRÚC JSON (Quan trọng)
        print("Step 3 JSON Data: ${profileRes.data}");

        if (mounted && profileRes.data != null) {
          setState(() {
            // LOGIC CŨ (SAI):
            // _currentPoints = profileRes.data['experiencePoints'] ?? 0;

            // LOGIC MỚI (THỬ 1 TRONG 2 CÁCH SAU TÙY VÀO JSON CỦA BẠN):

            // CÁCH 1: Nếu JSON lồng nhau (User -> userProfile -> points)
            if (profileRes.data['userProfile'] != null) {
              _currentPoints = profileRes.data['experiencePoints'] ?? 0;
            }
            // CÁCH 2: Nếu JSON phẳng (Backend đã map sẵn ra ngoài)
            else {
              _currentPoints = profileRes.data['experiencePoints'] ?? 0;
            }
          });
          print("Điểm đã lấy được: $_currentPoints");
        }
      } catch (e) {
        print("Lỗi lấy điểm: $e");
        setState(() => _currentPoints = 0);
      }

    } catch (e, stackTrace) {
      // Chỉ khi Step 1 hoặc 2 lỗi thì mới báo lỗi chung
      print("----------- LỖI CHÍNH -----------");
      print("Error: $e");
      print("StackTrace: $stackTrace");

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải danh sách: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _redeemVoucher(int voucherId, int cost) async {
    if (_currentPoints < cost) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Không đủ điểm!"), backgroundColor: Colors.red));
      return;
    }

    try {
      // --- SỬA TẠI ĐÂY ---
      // Backend đang dùng @RequestParam nên phải truyền tham số lên URL
      // Thay vì dùng data: {...}, ta nối chuỗi query string:
      await _dioClient.post(
        '/rewards/redeem?userId=${widget.userId}&voucherId=$voucherId',
      );
      // -------------------

      // Sau khi đổi xong thì load lại data để cập nhật điểm và danh sách
      await _fetchAllData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đổi quà thành công!"), backgroundColor: Colors.green));
        _tabController.animateTo(0); // Chuyển về tab kho voucher
      }

    } catch (e) {
      String msg = "Đổi quà thất bại";
      if (e is DioException && e.response != null) {
        // Backend trả về lỗi (ví dụ: Không đủ điểm, Voucher hết hạn...)
        msg = e.response?.data['message'] ?? msg;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  // ... (Phần UI build giữ nguyên như cũ) ...
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),

          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: "Kho Voucher"),
              Tab(text: "Đổi Thưởng"),
            ],
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                _buildMyVouchersTab(),
                _buildRedeemTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Copy lại 2 hàm _buildMyVouchersTab và _buildRedeemTab từ code cũ vào đây
  // Nhớ import Intl để dùng NumberFormat

  Widget _buildMyVouchersTab() {
    // ... (Code cũ của bạn)
    if (_myVouchers.isEmpty) {
      return _buildEmptyState("Bạn chưa có voucher nào.\nQua tab 'Đổi Thưởng' để săn quà nhé!");
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _myVouchers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _myVouchers[index];

        // --- CHÚ Ý: Cấu trúc JSON có thể thay đổi do @JsonIgnoreProperties ---
        // item['voucher'] bây giờ sẽ sạch sẽ hơn
        final voucher = item['voucher'];
        final bool isUsed = item['isUsed'] ?? false;

        final voucherEntity = Voucher(
          id: voucher['id'],
          code: voucher['code'],
          discountAmount: (voucher['discountAmount'] as num).toDouble(),
          expiryDate: DateTime.parse(voucher['expiryDate']),
          isActive: voucher['isActive'],
          usageLimit: 0,
        );

        return Opacity(
          opacity: isUsed ? 0.5 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.confirmation_number, color: isUsed ? Colors.grey : Colors.orange),
              title: Text(voucherEntity.code, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Giảm ${NumberFormat('#,###').format(voucherEntity.discountAmount)} đ"),
              trailing: isUsed
                  ? const Text("Đã dùng", style: TextStyle(color: Colors.grey))
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  Navigator.pop(context, voucherEntity);
                },
                child: const Text("Dùng", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRedeemTab() {
    // ... (Code cũ của bạn)
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.orange.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, color: Colors.orange, size: 28),
              const SizedBox(width: 10),
              Text(
                  "Điểm của bạn: $_currentPoints",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)
              ),
            ],
          ),
        ),

        Expanded(
          child: _redeemableVouchers.isEmpty
              ? _buildEmptyState("Chưa có voucher nào để đổi.")
              : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _redeemableVouchers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final voucher = _redeemableVouchers[index];
              final int cost = voucher['pointsRequired'] ?? 0;
              final bool canRedeem = _currentPoints >= cost;

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.card_giftcard, color: Colors.pink, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(voucher['code'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("Giảm ${NumberFormat('#,###').format(voucher['discountAmount'])} đ", style: const TextStyle(color: Colors.green)),
                            Text("Cần: $cost điểm", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canRedeem ? Colors.orange : Colors.grey.shade300,
                        ),
                        onPressed: canRedeem
                            ? () => _redeemVoucher(voucher['id'], cost)
                            : null,
                        child: const Text("Đổi", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}