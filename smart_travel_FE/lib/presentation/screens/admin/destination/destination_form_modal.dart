import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/params/destination_add_params.dart';
import 'package:smart_travel/domain/params/destination_update_params.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_event.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_state.dart';
import 'package:smart_travel/presentation/blocs/province/province_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/province_event.dart';
import 'package:smart_travel/presentation/blocs/province/province_state.dart';

class DestinationFormModal extends StatefulWidget {
  final dynamic destination;
  final VoidCallback onReset;

  const DestinationFormModal({
    Key? key,
    required this.destination,
    required this.onReset,
  }) : super(key: key);

  @override
  State<DestinationFormModal> createState() => _DestinationFormModalState();
}

class _DestinationFormModalState extends State<DestinationFormModal> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _latCtrl;
  late TextEditingController _lngCtrl;
  late TextEditingController _priceCtrl;
  late QuillController _quillCtrl;

  // State Variables
  String? _selectedCategory;
  int? _selectedProvinceId;
  bool _isFeatured = false;


  // Images
  List<dynamic> _existingImages = []; // List object ảnh từ server
  List<int> _imagesToDelete = []; // List ID ảnh cần xóa
  List<File> _newImages = []; // List File ảnh mới chọn

  // Opening Hours
  final Map<String, Map<String, String>> _openingHours = {
    'monday': {'start': '08:00', 'end': '17:00', 'status': 'open'},
    'tuesday': {'start': '08:00', 'end': '17:00', 'status': 'open'},
    'wednesday': {'start': '08:00', 'end': '17:00', 'status': 'open'},
    'thursday': {'start': '08:00', 'end': '17:00', 'status': 'open'},
    'friday': {'start': '08:00', 'end': '17:00', 'status': 'open'},
    'saturday': {'start': '08:00', 'end': '17:00', 'status': 'open'},
    'sunday': {'start': '08:00', 'end': '17:00', 'status': 'open'},
  };

  final List<String> _categories = [
    "Biển",
    "Thiên nhiên",
    "Văn hóa",
    "Giải trí",
    "Thể thao",
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _latCtrl = TextEditingController();
    _lngCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
    _quillCtrl = QuillController.basic();

    context.read<ProvinceBloc>().add(LoadProvince());

    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.destination != null) {
      final d = widget.destination;
      _nameCtrl.text = d.name;
      _addressCtrl.text = d.address!;
      _latCtrl.text = d.latitude.toString();
      _lngCtrl.text = d.longitude.toString();
      _priceCtrl.text = (d.entryFee ?? 0).toString();
      _selectedCategory = d.category;
      _selectedProvinceId = d.province?.id;
      _isFeatured = d.isFeatured;
      _existingImages = List.from(d.destinationImage ?? []);

      // Load Description
      try {
        if (d.description != null) {
          _quillCtrl.document = Document.fromJson(jsonDecode(d.description!));
        }
      } catch (_) {
        _quillCtrl.document = Document()..insert(0, d.description ?? "");
      }

      // Load Opening Hours
      if (d.openingHours != null) {
        try {
          Map<String, dynamic> parsed = d.openingHours ?? {};
          parsed.forEach((day, value) {
            if (_openingHours.containsKey(day)) {
              if (value == 'closed' || value == 'Đóng cửa') {
                _openingHours[day]!['status'] = 'closed';
              } else {
                final times = value.toString().split('-');
                if (times.length == 2) {
                  _openingHours[day]!['start'] = times[0].trim();
                  _openingHours[day]!['end'] = times[1].trim();
                  _openingHours[day]!['status'] = 'open';
                }
              }
            }
          });
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _priceCtrl.dispose();
    _quillCtrl.dispose();
    super.dispose();
  }

  // --- Logic Xử lý Ảnh ---
  Future<void> _pickImages() async {
    final totalImages = _existingImages.length + _newImages.length;

    if (totalImages >= 5) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text("Bạn chỉ được chọn tối đa 5 ảnh"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
      );
      return;
    }

    final List<XFile>? images = await ImagePicker().pickMultiImage();
    if (images == null || images.isEmpty) return;

    // Số slot còn trống
    final remaining = 5 - totalImages;

    // Chỉ lấy tối đa số lượng còn trống
    final limitedImages =
        images.take(remaining).map((x) => File(x.path)).toList();

    setState(() {
      _newImages.addAll(limitedImages);
    });

    // Nếu người dùng chọn nhiều hơn slot trống  báo lỗi
    if (images.length > remaining) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Chỉ thêm được tối đa $remaining ảnh nữa'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
      );
      return;
    }
  }

  void _removeNewImage(int index) {
    setState(() => _newImages.removeAt(index));
  }

  void _removeExistingImage(int index) {
    setState(() {
      final img = _existingImages[index];
      _imagesToDelete.add(img.id);
      _existingImages.removeAt(index);
    });
  }

  // --- Logic Submit ---
  void _onSubmit() {
    if (!_formKey.currentState!.validate() || _selectedProvinceId == null) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text("Vui lòng nhập đủ thông tin bắt buộc"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
      );
      return;
    }

    // Build Opening Hours JSON (String)
    Map<String, String> finalHours = {};
    _openingHours.forEach((day, data) {
      if (data['status'] == 'closed') {
        finalHours[day] = 'closed';
      } else {
        finalHours[day] = "${data['start']} - ${data['end']}";
      }
    });

    final openingHoursString = jsonEncode(finalHours);

    // Build Description JSON
    final descJson = jsonEncode(_quillCtrl.document.toDelta().toJson());

    // Call Bloc
    if (widget.destination != null) {
      // UPDATE EVENT
      final paramsUpdate= DestinationUpdateParams(
        destinationId: widget.destination.id,
        name: _nameCtrl.text.trim(),
        provinceId: _selectedProvinceId!, // chắc chắn không null vì đã validate
        description: descJson,
        category: _selectedCategory!,
        latitude: double.parse(_latCtrl.text),
        longitude: double.parse(_lngCtrl.text),
        address: _addressCtrl.text.trim(),
        entryFee: double.tryParse(_priceCtrl.text) ?? 0,
        openingHours: openingHoursString,
        isFeatured: _isFeatured,
        image: _newImages,
        imagesToDelete: _imagesToDelete
      );
      context.read<DestinationBloc>().add(UpdateDestinationEvent(paramsUpdate));
    } else {
      // CREATE EVENT
      final paramsAdd = DestinationAddParams(
        name: _nameCtrl.text.trim(),
        provinceId: _selectedProvinceId!, // chắc chắn không null vì đã validate
        description: descJson,
        category: _selectedCategory!,
        latitude: double.parse(_latCtrl.text),
        longitude: double.parse(_lngCtrl.text),
        address: _addressCtrl.text.trim(),
        entryFee: double.tryParse(_priceCtrl.text) ?? 0,
        openingHours: openingHoursString,
        isFeatured: _isFeatured,
        image: _newImages,
      );
      context.read<DestinationBloc>().add(AddDestinationEvent(paramsAdd));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DestinationBloc, DestinationState>(
      listener: (context, state) {
        if (state is AddDestinationSuccess || state is UpdateDestinationSuccess) {
          Navigator.pop(context);
          widget.onReset();
        }
        if (state is AddDestinationError) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Lỗi"),
              content: Text(state.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
        if (state is UpdateDestinationError) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Lỗi"),
              content: Text(state.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      },
      builder: (context, state) {
        bool isLoading = state is AddDestinationLoading || state is UpdateDestinationLoading;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 900),
            child: Stack(
              children: [
                // Nội dung chính
                Column(
                  children: [
                    _buildHeader(),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //TẤT CẢ CÁC FIELD
                              Row(
                                children: [
                                  Expanded(child: _buildTextField(_nameCtrl, "Tên địa điểm *")),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildCategoryDropdown()),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _buildProvinceDropdown()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextField(_addressCtrl, "Địa chỉ")),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _buildTextField(_latCtrl, "Vĩ độ (Lat) *", isNumber: true)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextField(_lngCtrl, "Kinh độ (Long) *", isNumber: true)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text("Giờ mở cửa", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              _buildOpeningHoursSection(),
                              const SizedBox(height: 24),
                              const Text("Mô tả chi tiết", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              _buildQuillEditor(),
                              const SizedBox(height: 24),
                              _buildImageSection(),
                              const SizedBox(height: 16),
                              CheckboxListTile(
                                value: _isFeatured,
                                onChanged: (v) => setState(() => _isFeatured = v!),
                                title: const Text("Đánh dấu là địa điểm nổi bật"),
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),

                    _buildFooter(),
                  ],
                ),

                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Lottie.asset(
                        'assets/lottie/travel_is_fun.json',
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.destination != null
                ? "Cập Nhật Địa Điểm"
                : "Thêm Địa Điểm Mới",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType:
          isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
      validator: (v) => v!.isEmpty ? "Không được để trống" : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: "Danh mục",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items:
          _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
      onChanged: (v) => setState(() => _selectedCategory = v),
    );
  }

  Widget _buildProvinceDropdown() {
    return BlocConsumer<ProvinceBloc, ProvinceState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is ProvinceLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is ProvinceLoaded) {
          final provinces = state.province;

          // DEBUG: In ra để kiểm tra dữ liệu
          print("=== Province Data Debug ===");
          for (var p in provinces) {
            print("ID: ${p.id}, Name: ${p.name}");
          }

          // Lọc bỏ các province có id null
          final validProvinces = provinces.where((p) => p.id != null).toList();

          // Sử dụng Map để loại bỏ trùng lặp theo id
          final uniqueProvincesMap = <int, dynamic>{};
          for (var p in validProvinces) {
            if (!uniqueProvincesMap.containsKey(p.id)) {
              uniqueProvincesMap[p.id] = p;
            }
          }

          // Chuyển Map thành List
          final uniqueProvinces = uniqueProvincesMap.values.toList();

          print("Original count: ${provinces.length}");
          print("Unique count: ${uniqueProvinces.length}");

          // Kiểm tra xem _selectedProvinceId có tồn tại trong danh sách không
          bool isValidValue = uniqueProvinces.any((p) => p.id == _selectedProvinceId);

          // Nếu _selectedProvinceId không hợp lệ, đặt lại thành null
          if (_selectedProvinceId != null && !isValidValue) {
            print("Warning: _selectedProvinceId $_selectedProvinceId not found in unique provinces");
            // Có thể set lại sau
          }

          return DropdownButtonFormField<int>(
            isExpanded: true,
            value: isValidValue ? _selectedProvinceId : null,
            hint: const Text("Chọn tỉnh thành"),
            decoration: InputDecoration(
              labelText: "Tỉnh thành *",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: uniqueProvinces.map((p) {
              return DropdownMenuItem<int>(
                value: p.id,
                child: Text(p.name ?? 'Không có tên'),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                _selectedProvinceId = v;
                print("Selected province ID: $v");
              });
            },
          );
        }
        if (state is ProvinceError) {
          return Text("Lỗi: ${state.message}");
        }
        return const Text("Không thể tải tỉnh thành");
      },
    );
  }

  Widget _buildOpeningHoursSection() {
    final days = {
      'monday': 'Thứ 2',
      'tuesday': 'Thứ 3',
      'wednesday': 'Thứ 4',
      'thursday': 'Thứ 5',
      'friday': 'Thứ 6',
      'saturday': 'Thứ 7',
      'sunday': 'CN',
    };

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children:
            days.entries.map((entry) {
              final dayKey = entry.key;
              final dayName = entry.value;
              final data = _openingHours[dayKey]!;
              final isClosed = data['status'] == 'closed';
              final isWeekend = dayKey == 'saturday' || dayKey == 'sunday';

              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isWeekend ? Colors.blue[50] : Colors.transparent,
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        dayName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (!isClosed) ...[
                      SizedBox(
                        width: 70,
                        child: TextFormField(
                          initialValue: data['start'],
                          style: const TextStyle(fontSize: 13),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(8),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => _openingHours[dayKey]!['start'] = v,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("-"),
                      ),
                      SizedBox(
                        width: 70,
                        child: TextFormField(
                          initialValue: data['end'],
                          style: const TextStyle(fontSize: 13),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(8),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => _openingHours[dayKey]!['end'] = v,
                        ),
                      ),
                    ] else
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Đóng cửa",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),

                    const Spacer(),
                    Switch(
                      value: !isClosed,
                      activeColor: Colors.blue,
                      onChanged: (isOpen) {
                        setState(() {
                          _openingHours[dayKey]!['status'] =
                              isOpen ? 'open' : 'closed';
                        });
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildQuillEditor() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          QuillSimpleToolbar(
            configurations: QuillSimpleToolbarConfigurations(
              controller: _quillCtrl,
              showFontFamily: false,
              showSearchButton: false,
              showInlineCode: false,
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 200,
            child: QuillEditor.basic(
              configurations:  QuillEditorConfigurations(
                controller: _quillCtrl,

                padding: EdgeInsets.all(12),
                placeholder: 'Nhập mô tả...',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Hình ảnh",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.upload),
              label: const Text("Tải ảnh lên"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Grid ảnh cũ
        if (_existingImages.isNotEmpty) ...[
          const Text(
            "Ảnh hiện có:",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _existingImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Image.network(
                      _existingImages[index].imageUrl ?? "",
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _removeExistingImage(index),
                        child: Container(
                          color: Colors.red,
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        // Grid ảnh mới
        if (_newImages.isNotEmpty) ...[
          const Text(
            "Ảnh mới chọn:",
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _newImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Image.file(
                      _newImages[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _removeNewImage(index),
                        child: Container(
                          color: Colors.red,
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        color: Colors.grey[50],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _onSubmit,
              child: Text(widget.destination != null ? "Cập Nhật" : "Thêm Mới"),
            ),
          ),
        ],
      ),
    );
  }
}
