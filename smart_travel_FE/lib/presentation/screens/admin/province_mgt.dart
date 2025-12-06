import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_travel/presentation/blocs/province/province_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/province_event.dart';
import 'dart:io';
import 'package:smart_travel/presentation/blocs/province/province_state.dart';

// Import BLoC (giả sử bạn đã có)
// import 'package:your_app/bloc/province/province_bloc.dart';
// import 'package:your_app/domain/entities/province.dart';

class ProvinceManagementScreen extends StatefulWidget {
  const ProvinceManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProvinceManagementScreen> createState() => _ProvinceManagementScreenState();
}

class _ProvinceManagementScreenState extends State<ProvinceManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedRegion;
  bool _isPopular = false;
  File? _selectedImage;
  String? _editingId;
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    // Trigger load provinces khi screen initialize
    context.read<ProvinceBloc>().add(LoadProvince());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _codeController.clear();
    _descriptionController.clear();
    _selectedRegion = null;
    _isPopular = false;
    _selectedImage = null;
    _editingId = null;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final File file = File(image.path);
      final int sizeInMb = file.lengthSync() ~/ (1024 * 1024);

      if (sizeInMb > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kích thước tệp quá lớn. Vui lòng chọn tệp dưới 5MB.')),
        );
        return;
      }

      setState(() {
        _selectedImage = file;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _showModal({dynamic province}) {
    if (province != null) {
      _nameController.text = province.name ?? '';
      _codeController.text = province.code ?? '';
      _selectedRegion = province.region;
      _descriptionController.text = province.description ?? '';
      _isPopular = province.isPopular ?? false;
      _editingId = province.id;
    } else {
      _resetForm();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Modal Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _editingId != null ? 'Chỉnh Sửa Tỉnh Thành' : 'Thêm Tỉnh Thành Mới',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    // Modal Body
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tên Tỉnh Thành
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Tên Tỉnh Thành *',
                              hintText: 'Nhập tên tỉnh thành',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Mã và Miền (2 cột)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _codeController,
                                  maxLength: 10,
                                  decoration: InputDecoration(
                                    labelText: 'Mã *',
                                    hintText: 'VD: HCMC',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    counterText: '',
                                  ),
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      _codeController.text = value.toUpperCase();
                                      _codeController.selection = TextSelection.fromPosition(
                                        TextPosition(offset: value.length),
                                      );
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedRegion,
                                  hint: const Text('Chọn miền'),
                                  decoration: InputDecoration(
                                    labelText: 'Miền *',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'Miền Bắc', child: Text('Miền Bắc')),
                                    DropdownMenuItem(value: 'Miền Trung', child: Text('Miền Trung')),
                                    DropdownMenuItem(value: 'Miền Nam', child: Text('Miền Nam')),
                                  ],
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      _selectedRegion = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Mô Tả
                          TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Mô Tả',
                              hintText: 'Nhập mô tả ngắn về tỉnh thành',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Hình Ảnh
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _selectedImage != null
                                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                      : (province?.imageUrl != null
                                      ? Image.network(
                                    province.imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    color: Colors.grey[100],
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  )),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _pickImage,
                                        icon: const Icon(Icons.upload),
                                        label: Text(_selectedImage != null ? 'Thay đổi ảnh' : 'Tải ảnh lên'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[200],
                                          foregroundColor: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'PNG, JPG. Tối đa 5MB.',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      if (_selectedImage != null)
                                        GestureDetector(
                                          onTap: _removeImage,
                                          child: const Text(
                                            'Xóa ảnh',
                                            style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Checkbox nổi bật
                          Row(
                            children: [
                              Checkbox(
                                value: _isPopular,
                                onChanged: (value) {
                                  setStateDialog(() {
                                    _isPopular = value ?? false;
                                  });
                                },
                              ),
                              const Text('Đánh dấu là tỉnh thành nổi bật'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Modal Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey[300]!)),
                        color: Colors.grey[50],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_nameController.text.isEmpty ||
                                    _codeController.text.isEmpty ||
                                    _selectedRegion == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Vui lòng điền đủ Tên, Mã và Miền'),
                                    ),
                                  );
                                  return;
                                }

                                // TODO: Gọi BLoC event để thêm/cập nhật
                                // context.read<ProvinceBloc>().add(
                                //   _editingId != null
                                //       ? UpdateProvince(...)
                                //       : AddProvince(...),
                                // );

                                Navigator.pop(context);
                                _resetForm();
                              },
                              child: Text(_editingId != null ? 'Cập Nhật' : 'Thêm Mới'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => _resetForm());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Tỉnh Thành'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<ProvinceBloc, ProvinceState>(
        builder: (context, state) {
          if (state is ProvinceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProvinceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${state.message}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProvinceBloc>().add(LoadProvince()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is ProvinceLoaded) {
            final provinces = state.province;

            // Lọc theo từ khóa tìm kiếm
            final filtered = provinces
                .where((p) =>
            p.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                p.code.toLowerCase().contains(_searchController.text.toLowerCase()))
                .toList();

            // Tính tổng trang
            final totalPages = (filtered.length / _itemsPerPage).ceil();
            final startIdx = (_currentPage - 1) * _itemsPerPage;
            final displayedProvinces =
            filtered.sublist(startIdx, (startIdx + _itemsPerPage).clamp(0, filtered.length));

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Quản Lý Tỉnh Thành',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Quản lý danh sách tỉnh thành và các thông tin liên quan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Toolbar
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) {
                              setState(() => _currentPage = 1);
                            },
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm theo tên hoặc mã...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _showModal(),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Table
                    if (displayedProvinces.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: const [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Không tìm thấy tỉnh thành'),
                              SizedBox(height: 8),
                              Text(
                                'Hãy thử thay đổi từ khóa tìm kiếm của bạn.',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Hình ảnh')),
                            DataColumn(label: Text('Tên Tỉnh')),
                            DataColumn(label: Text('Mã')),
                            DataColumn(label: Text('Miền')),
                            DataColumn(label: Text('Trạng Thái')),
                            DataColumn(label: Text('Điểm Đến')),
                            DataColumn(label: Text('Hành Động')),
                          ],
                          rows: displayedProvinces.map((province) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  province.imageUrl != null
                                        ? Image.network(
                                   province.imageUrl!,
                                    width: 50,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, url, error) =>
                                    const Icon(Icons.image, size: 24),
                                  )
                                      : const Icon(Icons.image, size: 24, color: Colors.grey),
                                ),
                                DataCell(Text(province.name)),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(province.code, style: const TextStyle(fontSize: 12)),
                                  ),
                                ),
                                DataCell(Text(province.region)),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: province.isPopular ? Colors.green[100] : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      province.isPopular ? 'Nổi bật' : 'Thường',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: province.isPopular ? Colors.green[800] : Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text((province.destinationCount ?? 0).toString())),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                                        onPressed: () => _showModal(province: province),
                                        tooltip: 'Chỉnh sửa',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Xác nhận xóa'),
                                              content: const Text(
                                                'Bạn chắc chắn muốn xóa tỉnh thành này? Thao tác này có thể ảnh hưởng đến các dữ liệu liên quan.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Hủy'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    // TODO: Gọi BLoC event để xóa
                                                    // context.read<ProvinceBloc>().add(DeleteProvince(province.id));
                                                    Navigator.pop(context);
                                                  },
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  child: const Text('Xóa'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        tooltip: 'Xóa',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Pagination
                    if (totalPages > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hiển thị ${startIdx + 1} - ${(startIdx + _itemsPerPage).clamp(0, filtered.length)} trên ${filtered.length}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: _currentPage > 1
                                    ? () {
                                  setState(() => _currentPage--);
                                }
                                    : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text('Trang $_currentPage / $totalPages'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: _currentPage < totalPages
                                    ? () {
                                  setState(() => _currentPage++);
                                }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}