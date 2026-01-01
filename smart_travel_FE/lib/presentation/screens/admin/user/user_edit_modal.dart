import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_event.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/core/utils/admin_permission_helper.dart';

class UserEditModal extends StatefulWidget {
  final dynamic user;

  const UserEditModal({Key? key, required this.user}) : super(key: key);

  @override
  State<UserEditModal> createState() => _UserEditModalState();
}

class _UserEditModalState extends State<UserEditModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameCtrl;
  late TextEditingController _phoneCtrl;
  String? _selectedRole;
  bool _canChangeRole = false;
  bool _isCheckingPermission = true;

  final List<String> _roles = ['USER', 'ADMIN', 'ADMINTOUR', 'ADMINHOTEL'];

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController(text: widget.user.fullName);
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _selectedRole = widget.user.role.toUpperCase();
    _checkRolePermission();
  }

  Future<void> _checkRolePermission() async {
    final canChange = await AdminPermissionHelper.canChangeRole(
      widget.user.role,
    );
    if (mounted) {
      setState(() {
        _canChangeRole = canChange;
        _isCheckingPermission = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AdminUserBloc>().add(
      UpdateUser(
        userId: widget.user.id,
        fullName: _fullNameCtrl.text.trim(),
        phone:
            _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
        role: _selectedRole,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminUserBloc, AdminUserState>(
      listener: (context, state) {
        if (state is AdminUserUpdateSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is AdminUserUpdateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        bool isLoading = state is AdminUserUpdateLoading;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                // Main content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gradient Header
                    _buildGradientHeader(),

                    // Form Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                controller: _fullNameCtrl,
                                label: 'Họ và tên *',
                                icon: Icons.person_rounded,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _phoneCtrl,
                                label: 'Số điện thoại',
                                icon: Icons.phone_rounded,
                                required: false,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              _buildRoleDropdown(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer with gradient buttons
                    _buildFooter(),
                  ],
                ),

                // Loading Overlay
                if (isLoading)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Lottie.asset(
                        'assets/lottie/travel_is_fun.json',
                        width: 150,
                        height: 150,
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

  Widget _buildGradientHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_rounded, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Chỉnh sửa người dùng',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Đóng',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = true,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (v) {
        if (required && (v == null || v.trim().isEmpty)) {
          return 'Không được để trống';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    // Show read-only field if cannot change role
    if (!_canChangeRole && !_isCheckingPermission) {
      return TextFormField(
        initialValue: _getRoleDisplayName(_selectedRole ?? 'USER'),
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Vai trò (Không thể thay đổi)',
          prefixIcon: Icon(Icons.admin_panel_settings, color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          helperText: 'ADMIN không được đổi role của ADMINTOUR/ADMINHOTEL',
          helperMaxLines: 2,
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Vai trò *',
        prefixIcon: Icon(Icons.admin_panel_settings, color: Colors.blue[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items:
          _roles.map((role) {
            IconData icon;
            Color color;
            String displayName;

            switch (role) {
              case 'ADMIN':
                icon = Icons.shield;
                color = Colors.orange;
                displayName = 'Admin';
                break;
              case 'ADMINTOUR':
                icon = Icons.tour;
                color = Colors.green;
                displayName = 'Admin Tour';
                break;
              case 'ADMINHOTEL':
                icon = Icons.hotel;
                color = Colors.purple;
                displayName = 'Admin Hotel';
                break;
              default:
                icon = Icons.person;
                color = Colors.blue;
                displayName = 'User';
            }

            return DropdownMenuItem(
              value: role,
              child: Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(displayName),
                ],
              ),
            );
          }).toList(),
      onChanged: (v) => setState(() => _selectedRole = v),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'Admin';
      case 'ADMINTOUR':
        return 'Admin Tour';
      case 'ADMINHOTEL':
        return 'Admin Hotel';
      default:
        return 'User';
    }
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Hủy'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey[400]!),
                foregroundColor: Colors.grey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.mainGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _onSubmit,
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Cập nhật',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
