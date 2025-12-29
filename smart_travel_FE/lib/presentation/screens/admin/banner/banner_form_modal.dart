import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/params/banner_create_params.dart';
import 'package:smart_travel/domain/params/banner_update_params.dart';
import 'package:smart_travel/presentation/blocs/banner/banner_bloc.dart';
import 'package:smart_travel/presentation/blocs/banner/banner_event.dart';
import 'package:smart_travel/presentation/blocs/banner/banner_state.dart';

class BannerFormModal extends StatefulWidget {
  final dynamic banner;
  final VoidCallback onReset;

  const BannerFormModal({Key? key, this.banner, required this.onReset}) : super(key: key);

  @override
  State<BannerFormModal> createState() => _BannerFormModalState();
}

class _BannerFormModalState extends State<BannerFormModal> {
  late TextEditingController _titleController;
  late TextEditingController _linkController;
  late TextEditingController _descController;
  late TextEditingController _imageUrlController; // Controller cho URL ảnh
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.banner?.title ?? '');
    _linkController = TextEditingController(text: widget.banner?.linkUrl ?? '');
    _descController = TextEditingController(text: widget.banner?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.banner?.imageUrl ?? '');
    _isActive = widget.banner?.active ?? true;

    // Lắng nghe thay đổi URL để cập nhật ảnh preview ngay lập tức
    _imageUrlController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.isEmpty || _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ Tiêu đề và Link ảnh")),
      );
      return;
    }

    if (widget.banner == null) {
      context.read<BannerBloc>().add(CreateBannerEvent(
        BannerCreateParams(
          title: _titleController.text,
          imageUrl: _imageUrlController.text, // Lấy link từ text field
          linkUrl: _linkController.text,
          description: _descController.text,
        ),
      ));
    } else {
      context.read<BannerBloc>().add(UpdateBannerEvent(
        BannerUpdateParams(
          id: widget.banner.id,
          title: _titleController.text,
          imageUrl: _imageUrlController.text,
          linkUrl: _linkController.text,
          description: _descController.text,
          active: _isActive,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: BlocConsumer<BannerBloc, BannerState>(
        // 1. LISTENER: Xử lý các "hành động" (Side effects)
        listener: (context, state) {
          if (state is BannerActionSuccess) {
            // Chỉ tắt form khi thành công
            Navigator.pop(context); // Đóng form
          } else if (state is BannerActionError) {
            // Hiện lỗi nhưng KHÔNG tắt form
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
        // 2. BUILDER: Xử lý hiển thị giao diện (Nút bấm loading)
        builder: (context, state) {
          final bool isLoading = state is BannerActionLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.banner == null ? "Thêm Banner" : "Sửa Banner",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Image Preview
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _imageUrlController.text.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageUrlController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text("Link ảnh lỗi", style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.image_outlined, size: 40), Text("Chưa có link ảnh")],
                  ),
                ),
                const SizedBox(height: 16),

                // Input fields (Vô hiệu hóa khi đang load để tránh sửa dữ liệu lúc đang gửi)
                TextField(
                  controller: _imageUrlController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: "Link ảnh (URL) *",
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(labelText: "Tiêu đề banner *", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _linkController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(labelText: "Link điều hướng", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  enabled: !isLoading,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: "Mô tả", border: OutlineInputBorder()),
                ),

                SwitchListTile(
                  title: const Text("Kích hoạt"),
                  value: _isActive,
                  onChanged: isLoading ? null : (v) => setState(() => _isActive = v),
                ),

                const SizedBox(height: 20),

                // Nút bấm xử lý Loading
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        child: const Text("Hủy"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text("Lưu"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}