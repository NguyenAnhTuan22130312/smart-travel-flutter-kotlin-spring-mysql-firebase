import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';
import 'package:smart_travel/domain/params/province_add_params.dart';
import 'package:smart_travel/domain/params/province_update_params.dart';
import 'package:smart_travel/presentation/blocs/province/province_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/province_event.dart';
import 'package:smart_travel/presentation/blocs/province/province_state.dart';

class ProvinceFormModal extends StatefulWidget {
  final dynamic province;
  final VoidCallback onReset;

  const ProvinceFormModal({
    Key? key,
    this.province,
    required this.onReset,
  }) : super(key: key);

  @override
  State<ProvinceFormModal> createState() => _ProvinceFormModalState();
}

class _ProvinceFormModalState extends State<ProvinceFormModal> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late QuillController _quillController;

  String? _selectedRegion;
  bool _isPopular = false;
  File? _selectedImage;
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    _quillController = QuillController.basic();
    if (widget.province != null && widget.province.description != null) {
      try {
        // Server trả về JSON (Định dạng của Quill)
        final jsonDesc = jsonDecode(widget.province.description);
        _quillController.document = Document.fromJson(jsonDesc);
      } catch (e) {
        //  Server trả về Text thường
        // Tạm thời hiển thị như text thường
        _quillController.document = Document()..insert(0, widget.province.description);
      }
    }
    _initializeFormData();
  }

  void _initializeFormData() {
    if (widget.province != null) {
      _nameController.text = widget.province.name ?? '';
      _codeController.text = widget.province.code ?? '';
      _selectedRegion = widget.province.region;
      _isPopular = widget.province.isPopular ?? false;
      _editingId = widget.province.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final File file = File(image.path);
      final int sizeInMb = file.lengthSync() ~/ (1024 * 1024);

      if (sizeInMb > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kích thước tệp quá lớn. Vui lòng chọn tệp dưới 5MB.'),
          ),
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

  void _resetForm() {
    _nameController.clear();
    _codeController.clear();
    _quillController.clear();
    _selectedRegion = null;
    _isPopular = false;
    _selectedImage = null;
    _editingId = null;
    widget.onReset();
  }

  void _submitForm() {
    // Quill lưu dưới dạng Delta (JSON)
    final delta = _quillController.document.toDelta();
    final jsonList = delta.toJson(); // Đây là List<dynamic>
    final jsonString = jsonEncode(jsonList); // Chuyển thành String để lưu vào DB
    if (_nameController.text.isEmpty ||
        _codeController.text.isEmpty ||
        _selectedRegion == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Lỗi"),
          content: Text("Vui lòng điển đẩy đủ tên, mã và miền tỉnh thành"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    if (_editingId != null) {
      // Chỉ tạo khi update
      final paramsUpdate = ProvinceUpdateParams(
        provinceId: _editingId!,
        name: _nameController.text,
        code: _codeController.text,
        region: _selectedRegion!,
        description: jsonString,
        isPopular: _isPopular,
        image: _selectedImage,
      );

      context.read<ProvinceBloc>().add(UpdateProvince(paramsUpdate));
    } else {
      // Tạo params khi thêm mới
      final params = ProvinceAddParams(
        name: _nameController.text,
        code: _codeController.text,
        region: _selectedRegion!,
        description: jsonString,
        isPopular: _isPopular,
        image: _selectedImage,
      );

      context.read<ProvinceBloc>().add(AddProvince(params));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProvinceBloc, ProvinceState>(
      listener: (context, state) {
        if (state is ProvinceAddSuccess || state is ProvinceUpdateSuccess) {
          Navigator.of(context).pop(); // đóng modal
          _resetForm();
        }

        if (state is AddProvinceError ) {
          // Hiện dialog lỗi
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
        if (state is ProvinceUpdateError ) {
          // Hiện dialog lỗi
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
        bool isLoading = state is ProvinceAdding || state is ProvinceUpdateLoading;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    _buildBody(),
                    _buildFooter(),
                  ],
                ),
              ),

              //LOADING OVERLAY
              if (isLoading)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Lottie.asset(
                      'assets/lottie/travel_is_fun.json',
                      width: 200,
                      height: 200,
                      repeat: true,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
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
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNameField(),
          const SizedBox(height: 16),
          _buildCodeAndRegionFields(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          _buildImageSection(),
          const SizedBox(height: 16),
          _buildPopularCheckbox(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Tên Tỉnh Thành *',
        hintText: 'Nhập tên tỉnh thành',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildCodeAndRegionFields() {
    return Row(
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
              setState(() {
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: const [
              DropdownMenuItem(value: 'Miền Bắc', child: Text('Miền Bắc')),
              DropdownMenuItem(value: 'Miền Trung', child: Text('Miền Trung')),
              DropdownMenuItem(value: 'Miền Nam', child: Text('Miền Nam')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedRegion = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mô Tả Chi Tiết', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // Khung chứa Editor
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // THANH CÔNG CỤ (Toolbar)
              QuillSimpleToolbar(
                configurations:  QuillSimpleToolbarConfigurations(
                  controller: _quillController,
                  showFontFamily: false, // Tắt bớt mấy cái không cần
                  showSearchButton: false,
                  showInlineCode: false,
                  showAlignmentButtons: false,
                  showDividers: false,
                  showQuote: false,
                  showIndent: false,
                ),
              ),
              const Divider(height: 1),

              // VÙNG SOẠN THẢO (Editor)
              SizedBox(
                height: 200, // Cần set chiều cao cố định hoặc dùng Expanded nếu cha cho phép
                child: QuillEditor.basic(
                  configurations:  QuillEditorConfigurations(
                    controller: _quillController,
                    padding: EdgeInsets.all(16),
                    placeholder: 'Nhập mô tả bài viết, chèn ảnh...',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildImagePreview(),
          const SizedBox(width: 16),
          Expanded(
            child: _buildImageUploadSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _selectedImage != null
          ? Image.file(_selectedImage!, fit: BoxFit.cover)
          : (widget.province?.imageUrl != null
          ? Image.network(
        widget.province.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, url, error) =>
        const Icon(Icons.image, size: 24),
      )
          : Container(
        color: Colors.grey[100],
        child: const Icon(Icons.image, color: Colors.grey),
      )),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPopularCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isPopular,
          onChanged: (value) {
            setState(() {
              _isPopular = value ?? false;
            });
          },
        ),
        const Text('Đánh dấu là tỉnh thành nổi bật'),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
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
              onPressed: _submitForm,
              child: Text(_editingId != null ? 'Cập Nhật' : 'Thêm Mới'),
            ),
          ),
        ],
      ),
    );
  }
}