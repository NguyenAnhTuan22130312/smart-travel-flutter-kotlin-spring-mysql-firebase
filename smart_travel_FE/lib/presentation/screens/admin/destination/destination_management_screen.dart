import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_event.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_state.dart';
import 'package:smart_travel/presentation/screens/admin/destination/destination_form_modal.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

class DestinationManagementScreen extends StatefulWidget {
  const DestinationManagementScreen({Key? key}) : super(key: key);

  @override
  State<DestinationManagementScreen> createState() => _DestinationManagementScreenState();
}

class _DestinationManagementScreenState extends State<DestinationManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _categoryFilter = "Tất cả";
  final List<String> _categories = ["Tất cả", "Biển", "Thiên nhiên", "Văn hóa", "Giải trí", "Thể thao"];

  // Giả lập phân trang
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    // Load dữ liệu
    context.read<DestinationBloc>().add(LoadAllDestinations(loadAll: true));
  }

  void _showFormModal({dynamic destination}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DestinationFormModal(
        destination: destination,
        onReset: () => setState(() => _currentPage = 1),
      ),
    );
  }

  // --- MODAL CHI TIẾT
  void _showDetailDialog(DestinationEntity destination) {
    // Cấu hình Quill Controller Read-only
    QuillController readOnlyController;
    try {
      if (destination.description != null && destination.description!.isNotEmpty) {
        final jsonDesc = jsonDecode(destination.description!);
        readOnlyController = QuillController(
          document: Document.fromJson(jsonDesc),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        readOnlyController = QuillController.basic();
      }
    } catch (e) {
      readOnlyController = QuillController(
        document: Document()..insert(0, destination.description ?? ''),
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
            // 1. Ảnh Header
            Stack(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: destination.destinationImage != null && destination.destinationImage!.isNotEmpty
                      ? Image.network(
                    destination.destinationImage![0].imageUrl ?? "", // lấy ảnh đầu tiên
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    "assets/images/img_4.png",
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close, size: 20, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Nội dung
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên & Badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(destination.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        if (destination.isFeatured)
                          const Icon(Icons.star, color: Colors.amber),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Danh mục & Tỉnh
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildTag(destination.category!, Colors.purple),
                        _buildTag(destination.province?.name ?? 'Unknown', Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Địa chỉ
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(child: Text(destination.address!, style: const TextStyle(color: Colors.grey))),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Text("Giờ mở cửa:", style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildOpeningHoursTable(destination.openingHours ?? {}),

                    const SizedBox(height: 16),
                    const Text("Mô tả:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    QuillEditor.basic(
                      configurations: QuillEditorConfigurations(
                        controller: readOnlyController,
                        showCursor: false,
                        enableInteractiveSelection: false,
                        sharedConfigurations: const QuillSharedConfigurations(
                          locale: Locale('vi'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // Nút thao tác
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showFormModal(destination: destination);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text("Sửa"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showDeleteConfirm(destination);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red),
                            icon: const Icon(Icons.delete),
                            label: const Text("Xóa"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpeningHoursTable(Map<String, dynamic> hours) {
    if (hours.isEmpty) return const Text("Chưa cập nhật", style: TextStyle(fontStyle: FontStyle.italic));
    final days = {
      'monday': 'Thứ 2', 'tuesday': 'Thứ 3', 'wednesday': 'Thứ 4',
      'thursday': 'Thứ 5', 'friday': 'Thứ 6', 'saturday': 'Thứ 7', 'sunday': 'CN'
    };

    return Column(
      children: days.entries.map((entry) {
        final time = hours[entry.key] ?? 'Đóng cửa';
        final isClosed = time == 'closed' || time == 'Đóng cửa';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.value, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                  isClosed ? "Đóng cửa" : time,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isClosed ? Colors.red : Colors.black87
                  )
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTag(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color[50], borderRadius: BorderRadius.circular(4), border: Border.all(color: color[100]!)),
      child: Text(text, style: TextStyle(fontSize: 11, color: color[700])),
    );
  }

  void _showDeleteConfirm(DestinationEntity destination) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa '${destination.name}' không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              context.read<DestinationBloc>().add(DeleteDestinationEvent(destination.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Xóa"),
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
        title: const Text('Quản Lý Địa Điểm', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.mainGradient,
          ),
        ),
      ),
      body: BlocConsumer<DestinationBloc, DestinationState>(
        listener: (context, state) {
          if(state is AddDestinationSuccess){
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
          if(state is UpdateDestinationSuccess){
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
          if(state is DeleteDestinationSuccess){
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Xóa thành công',
                message: "Tỉnh thành đã được xóa thành công",
                contentType: ContentType.success,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
          if(state is DeleteDestinationError){
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Xóa thất bại' ,
                message: "Xóa tỉnh thành thất bại: : ${state.message}",
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
        },
        builder: (context, state) {
          if (state is DeleteDestinationLoading) return Center(child: Lottie.asset('assets/lottie/travel_is_fun.json', width: 150));
          if (state is FilterDestinationLoading) return Center(child: Lottie.asset('assets/lottie/travel_is_fun.json', width: 150));
          if (state is FilterDestinationLoaded) {
            return Column(
              children: [
                _buildFilterBar(),
                Expanded(child: _buildList(state.destinations)),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormModal(),
        label: const Text("Thêm mới"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.green,
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState((){}),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm địa điểm...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_,__) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _categoryFilter == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) => setState(() => _categoryFilter = cat),
                  selectedColor: AppColors.green,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildList(List<dynamic> destinations) {
    // Filter Logic
    final filtered = destinations.where((d) {
      final matchesSearch = d.name.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCat = _categoryFilter == "Tất cả" || d.category == _categoryFilter;
      return matchesSearch && matchesCat;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
            const Text("Không tìm thấy địa điểm nào", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_,__) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => _showDetailDialog(item),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item.destinationImage != null && item.destinationImage!.isNotEmpty
                        ? Image.network(
                      item.destinationImage![0].imageUrl ?? "", // lấy ảnh đầu tiên
                      height: 100,
                      width: 120,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      "assets/images/img_4.png",
                      height: 100,
                      width: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            if (item.isFeatured) const Icon(Icons.star, size: 16, color: Colors.amber),
                          ],
                        ),
                        Text(item.address, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildTag(item.category, Colors.purple),
                            const SizedBox(width: 8),

                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildTag(item.province?.name ?? "", Colors.blue),
                          ],
                        )
                      ],
                    ),
                  ),
                  // Menu
                  PopupMenuButton(
                    onSelected: (val) {
                      if(val == 'edit') _showFormModal(destination: item);
                      if(val == 'delete') _showDeleteConfirm(item);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text("Sửa")])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text("Xóa")])),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}