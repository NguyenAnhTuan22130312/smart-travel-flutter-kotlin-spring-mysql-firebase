import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_travel/core/services/image_upload_service.dart';
import 'package:smart_travel/injection_container.dart' as di;

class AvatarPickerWidget extends StatefulWidget {
  final String? currentAvatarUrl;
  final Function(String?) onAvatarChanged;
  final bool isLoading;

  const AvatarPickerWidget({
    Key? key,
    this.currentAvatarUrl,
    required this.onAvatarChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<AvatarPickerWidget> createState() => _AvatarPickerWidgetState();
}

class _AvatarPickerWidgetState extends State<AvatarPickerWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Show upload confirmation dialog
        if (mounted) {
          _showUploadConfirmation();
        }
      }
    } catch (e) {
      _showError('Không thể chọn ảnh: $e');
    }
  }

  void _showUploadConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Upload Avatar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImage!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            const Text('Bạn có muốn upload ảnh này làm avatar?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedImage = null;
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _uploadAvatar();
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadAvatar() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Get ImageUploadService from dependency injection
      final imageUploadService = di.sl<ImageUploadService>();
      
      // Upload to Cloudinary via backend
      final avatarUrl = await imageUploadService.uploadAvatar(_selectedImage!);
      
      // Call callback to update parent widget
      widget.onAvatarChanged(avatarUrl);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload avatar thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Upload thất bại: $e');
    } finally {
      setState(() {
        _isUploading = false;
        _selectedImage = null;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (widget.currentAvatarUrl != null && widget.currentAvatarUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa avatar', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onAvatarChanged(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUploading || widget.isLoading ? null : _showImageSourceDialog,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!)
                : (widget.currentAvatarUrl != null && widget.currentAvatarUrl!.isNotEmpty
                    ? NetworkImage(widget.currentAvatarUrl!)
                    : null) as ImageProvider?,
            child: widget.currentAvatarUrl == null || widget.currentAvatarUrl!.isEmpty
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey[600],
                  )
                : null,
          ),
          if (_isUploading || widget.isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                _isUploading || widget.isLoading ? Icons.hourglass_empty : Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
