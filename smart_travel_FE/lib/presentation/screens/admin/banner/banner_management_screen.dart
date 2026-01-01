import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_travel/presentation/blocs/banner/banner_bloc.dart';
import 'package:smart_travel/presentation/blocs/banner/banner_event.dart';
import 'package:smart_travel/presentation/blocs/banner/banner_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'banner_form_modal.dart'; // Đảm bảo đúng path

class BannerManagementScreen extends StatefulWidget {
  const BannerManagementScreen({Key? key}) : super(key: key);

  @override
  State<BannerManagementScreen> createState() => _BannerManagementScreenState();
}

class _BannerManagementScreenState extends State<BannerManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    context.read<BannerBloc>().add(LoadAllBanner());
  }

  void _showBannerModal({dynamic banner}) {
    showDialog(
      context: context,
      builder: (BuildContext context) => BannerFormModal(
        banner: banner,
        onReset: () => setState(() => _currentPage = 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Banner', style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.mainGradient)),
      ),
      body: BlocConsumer<BannerBloc, BannerState>(
        listener: (context, state) {
          if (state is BannerActionSuccess) {
            _showSnackBar("Thành công", state.message, ContentType.success);
            // Nếu xóa banner cuối cùng của trang, quay lại trang trước
            setState(() => _currentPage = 1);
          }
          if (state is BannerActionError) {
            _showSnackBar("Thất bại", state.message, ContentType.failure);
          }
        },
        builder: (context, state) {
          if (state is BannerDataLoading) {
            return Center(child: Lottie.asset('assets/lottie/travel_is_fun.json', width: 150));
          }
          if (state is BannerData) {
            return _buildBodyContent(state);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBannerModal(),
        label: const Text("Thêm Banner"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildBodyContent(BannerData state) {
    final banners = state.banners;
    final filtered = banners.where((b) => b.title.toLowerCase().contains(_searchController.text.toLowerCase())).toList();

    // Logic phân trang
    final totalPages = (filtered.length / _itemsPerPage).ceil().clamp(1, 999);
    final startIdx = (_currentPage - 1) * _itemsPerPage;
    final displayed = filtered.sublist(startIdx, (startIdx + _itemsPerPage).clamp(0, filtered.length));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 16),
          Expanded(
            child: displayed.isEmpty
                ? const Center(child: Text("Không tìm thấy banner nào"))
                : ListView.separated(
              itemCount: displayed.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) => _buildBannerCard(displayed[index]),
            ),
          ),
          _buildPagination(totalPages),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm tiêu đề banner...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildBannerCard(dynamic banner) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(banner.imageUrl, width: 100, height: 60, fit: BoxFit.cover),
        ),
        title: Text(banner.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(banner.linkUrl ?? "Không có link", maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            _buildStatusBadge(banner.active),
          ],
        ),
        trailing: PopupMenuButton(
          onSelected: (val) {
            if (val == 'edit') _showBannerModal(banner: banner);
            if (val == 'delete') _confirmDelete(banner);
  },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text("Sửa")),
            const PopupMenuItem(value: 'delete', child: Text("Xóa", style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: active ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(active ? "Đang chạy" : "Tạm dừng",
          style: TextStyle(fontSize: 10, color: active ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null),
        Text('$_currentPage / $totalPages'),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null),
      ],
    );
  }
  void _confirmDelete(dynamic banner) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text("Xác nhận xóa"),
            ],
          ),
          content: Text("Bạn có chắc chắn muốn xóa banner '${banner.title}' không? Hành động này không thể hoàn tác."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<BannerBloc>().add(DeleteBannerEvent(banner.id));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Xóa"),
            ),
          ],
        );
      },
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
}