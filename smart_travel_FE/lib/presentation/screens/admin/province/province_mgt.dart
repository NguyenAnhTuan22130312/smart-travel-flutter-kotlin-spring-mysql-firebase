import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_travel/presentation/blocs/province/province_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/province_event.dart';
import 'package:smart_travel/presentation/blocs/province/province_state.dart';
import 'package:smart_travel/presentation/screens/admin/province/province_form_modal.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

class ProvinceManagementScreen extends StatefulWidget {
  const ProvinceManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProvinceManagementScreen> createState() =>
      _ProvinceManagementScreenState();
}

class _ProvinceManagementScreenState extends State<ProvinceManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    context.read<ProvinceBloc>().add(LoadProvince());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hàm mở Modal thêm/sửa
  void _showProvinceModal({dynamic province}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProvinceFormModal(
          province: province,
          onReset: () {
            setState(() => _currentPage = 1);
          },
        );
      },
    );
  }

  // Hàm hiển thị chi tiết
  void _showDetailDialog(dynamic province) {
    QuillController readOnlyController;
    try {
      //decode JSON
      if (province.description != null && province.description!.isNotEmpty) {
        final jsonDesc = jsonDecode(province.description!);
        readOnlyController = QuillController(
          document: Document.fromJson(jsonDesc),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        // Nếu null hoặc rỗng
        readOnlyController = QuillController.basic();
      }
    } catch (e) {
      // Nếu lỗi decode (do dữ liệu cũ là text thường), load như text
      readOnlyController = QuillController(
        document: Document()..insert(0, province.description ?? ''),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ảnh Header
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: province.imageUrl != null
                      ? Image.network(
                    province.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  )
                      : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),

            // Nội dung chi tiết
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          province.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildStatusBadge(province.isPopular),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          province.code,
                          style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(province.region, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Mô tả:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  // --- TRÌNH HIỂN THỊ QUILL
                  QuillEditor.basic(
                    configurations:  QuillEditorConfigurations(
                      controller: readOnlyController, // Controller đã tạo ở trên
                      // Cấu hình hiển thị
                      showCursor: false,     // Ẩn con trỏ
                      enableInteractiveSelection: false, // Tắt chọn text (tuỳ chọn)
                      padding: EdgeInsets.zero, // Bỏ padding mặc định
                      sharedConfigurations: QuillSharedConfigurations(
                        locale: Locale('vi'), // Hỗ trợ tiếng Việt nếu cần
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.map, size: 20, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text("Số điểm đến: ${province.destinationCount ?? 0}"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showProvinceModal(province: province);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("Chỉnh sửa"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showDeleteConfirmDialog(province);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text("Xóa"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(dynamic province) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Text.rich(
          TextSpan(
            text: 'Bạn chắc chắn muốn xóa tỉnh ',
            style: const TextStyle(color: Colors.black87),
            children: [
              TextSpan(
                text: province.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?\nThao tác này không thể hoàn tác.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProvinceBloc>().add(DeleteProvince(province.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xóa vĩnh viễn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Quản Lý Tỉnh Thành', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.mainGradient, // ✔ gradient ở đây!
          ),
        ),
      ),
      body: BlocConsumer<ProvinceBloc, ProvinceState>(
        listener: (context, state) {
          if (state is ProvinceAddSuccess) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Thêm thành công',
                message: "Tỉnh thành đã được thêm thành công",
                contentType: ContentType.success,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
          if (state is ProvinceUpdateSuccess) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Cập nhật thành công',
                message: "Tỉnh thành đã được cập nhật thành công",
                contentType: ContentType.success,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
          if (state is ProvinceDeleteSuccess) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Xóa thành công',
                message: "Tỉnh thành đã được xóa",
                contentType: ContentType.success,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
            setState(() => _currentPage = 1);
          }
          if (state is ProvinceDeleteError) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Xóa thất bại',
                message: state.message,
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
        },
        builder: (context, state) {
          // Xử lý loading overlay
          if (state is ProvinceDeleteLoading || state is ProvinceUpdateLoading) {
            return Stack(
              children: [
                _buildBodyContent(state is ProvinceLoaded ? state : ProvinceLoaded(const [])),
                Container(
                  color: Colors.black26,
                  child: Center(
                    child: Lottie.asset('assets/lottie/travel_is_fun.json', width: 150),
                  ),
                ),
              ],
            );
          }

          if (state is ProvinceError) return _buildErrorState(state);
          if (state is ProvinceLoaded) return _buildBodyContent(state);
          if (state is ProvinceLoading) {
            return Center(child: Lottie.asset('assets/lottie/travel_is_fun.json', width: 150));
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProvinceModal(),
        label: const Text("Thêm mới"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.green,
      ),
    );
  }

  Widget _buildBodyContent(ProvinceLoaded state) {
    final provinces = state.province;
    final filtered = provinces.where((p) =>
    p.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
        p.code.toLowerCase().contains(_searchController.text.toLowerCase())
    ).toList();

    // Logic phân trang
    final totalPages = filtered.isEmpty ? 1 : (filtered.length / _itemsPerPage).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    if (_currentPage < 1) _currentPage = 1;
    final startIdx = (_currentPage - 1) * _itemsPerPage;
    final endIdx = (startIdx + _itemsPerPage).clamp(0, filtered.length);
    final displayedProvinces = filtered.isEmpty ? [] : filtered.sublist(startIdx, endIdx);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          _buildSearchAndFilter(),
          const SizedBox(height: 16),
          Expanded(
            child: displayedProvinces.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              itemCount: displayedProvinces.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildProvinceCard(displayedProvinces[index]),
            ),
          ),
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildPagination(totalPages, startIdx, displayedProvinces.length, filtered.length),
            ),
        ],
      ),
    );
  }
  Widget _buildSearchAndFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() => _currentPage = 1),
        decoration: const InputDecoration(
          hintText: 'Tìm kiếm tên, mã tỉnh...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: Icon(Icons.filter_list, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildProvinceCard(dynamic province) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailDialog(province), // Click vào card để hiện chi tiết
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: province.imageUrl != null
                    ? Image.network(
                  province.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image)),
                )
                    : Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image)),
              ),
              const SizedBox(width: 16),

              // Thông tin chính
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            province.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (province.isPopular)
                          const Icon(Icons.star, size: 16, color: Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${province.code} • ${province.region}",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusBadge(province.isPopular),
                  ],
                ),
              ),

              // Nút Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') _showProvinceModal(province: province);
                  if (value == 'delete') _showDeleteConfirmDialog(province);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [Icon(Icons.edit, size: 20, color: Colors.blue), SizedBox(width: 8), Text('Sửa')]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Xóa')]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPopular) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isPopular ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isPopular ? Colors.green[200]! : Colors.grey[300]!),
      ),
      child: Text(
        isPopular ? 'Nổi bật' : 'Thường',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isPopular ? Colors.green[700] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Không tìm thấy dữ liệu', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildErrorState(ProvinceError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(state.message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<ProvinceBloc>().add(LoadProvince()),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int totalPages, int startIdx, int displayedCount, int totalCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
          child: Text('$_currentPage / $totalPages', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
        ),
      ],
    );
  }
}
