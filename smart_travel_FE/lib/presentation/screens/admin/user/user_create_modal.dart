import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_event.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

class UserCreateModal extends StatefulWidget {
  const UserCreateModal({Key? key}) : super(key: key);

  @override
  State<UserCreateModal> createState() => _UserCreateModalState();
}

class _UserCreateModalState extends State<UserCreateModal> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  late QuillController _bioQuillCtrl;

  // State
  String _selectedRole = 'USER';
  String? _selectedGender;
  DateTime? _selectedDate;
  bool _obscurePassword = true;

  final List<String> _genders = ['Nam', 'Nữ', 'Khác'];

  @override
  void initState() {
    super.initState();
    _bioQuillCtrl = QuillController.basic();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _bioQuillCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Convert Quill document to JSON
    final bioJson =
        _bioQuillCtrl.document.isEmpty()
            ? null
            : jsonEncode(_bioQuillCtrl.document.toDelta().toJson());

    context.read<AdminUserBloc>().add(
      CreateUser(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        role: _selectedRole,
        gender: _selectedGender,
        dateOfBirth:
            _selectedDate != null
                ? "${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
                : null,
        address:
            _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        country:
            _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim(),
        bio: bioJson,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminUserBloc, AdminUserState>(
      listener: (context, state) {
        if (state is AdminUserCreateSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is AdminUserCreateError) {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
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
        bool isLoading = state is AdminUserCreateLoading;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildGradientHeader(),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Required fields
                              _buildSectionTitle('Thông tin bắt buộc'),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _nameCtrl,
                                label: 'Họ và tên *',
                                icon: Icons.person_rounded,
                                validator:
                                    (v) =>
                                        v!.isEmpty
                                            ? "Vui lòng nhập họ tên"
                                            : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _emailCtrl,
                                label: 'Email *',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v!.isEmpty) return "Vui lòng nhập email";
                                  if (!RegExp(
                                    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(v)) {
                                    return "Email không hợp lệ";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildPasswordField(),
                              const SizedBox(height: 16),
                              _buildRoleDropdown(),

                              const SizedBox(height: 24),
                              _buildSectionTitle('Thông tin liên hệ'),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _phoneCtrl,
                                label: 'Số điện thoại',
                                icon: Icons.phone_rounded,
                                keyboardType: TextInputType.phone,
                                required: false,
                                validator: (v) {
                                  if (v != null && v.isNotEmpty) {
                                    if (!RegExp(
                                      r'^[0-9]{10,11}$',
                                    ).hasMatch(v)) {
                                      return "Số điện thoại phải có 10-11 chữ số";
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _addressCtrl,
                                label: 'Địa chỉ',
                                icon: Icons.home_outlined,
                                required: false,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _cityCtrl,
                                      label: 'Thành phố',
                                      icon: Icons.location_city_outlined,
                                      required: false,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _countryCtrl,
                                      label: 'Quốc gia',
                                      icon: Icons.public_outlined,
                                      required: false,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),
                              _buildSectionTitle('Thông tin cá nhân'),
                              const SizedBox(height: 12),
                              _buildGenderDropdown(),
                              const SizedBox(height: 16),
                              _buildDatePicker(),
                              const SizedBox(height: 16),
                              const Text(
                                'Giới thiệu bản thân',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildBioQuillEditor(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildFooter(),
                  ],
                ),

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

  Widget _buildBioQuillEditor() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          QuillSimpleToolbar(
            configurations:  QuillSimpleToolbarConfigurations(
              controller: _bioQuillCtrl,
              showFontFamily: false,
              showSearchButton: false,
              showInlineCode: false,
              showCodeBlock: false,
              showSubscript: false,
              showSuperscript: false,
              showFontSize: false,
              showSmallButton: false,
              showBackgroundColorButton: false,
              showClearFormat: false,
              showAlignmentButtons: true,
              showListCheck: true,
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 150,
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                controller: _bioQuillCtrl,
                padding: EdgeInsets.all(12),
                placeholder: 'Nhập giới thiệu bản thân...',
              ),
            ),
          ),
        ],
      ),
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
              Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Tạo người dùng mới',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator:
          validator ??
          (v) {
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

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      validator: (v) {
        if (v == null || v.isEmpty) return "Vui lòng nhập mật khẩu";
        if (v.length < 6) return "Mật khẩu phải có ít nhất 6 ký tự";
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Mật khẩu *',
        prefixIcon: Icon(Icons.lock_outline, color: Colors.blue[700]),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[600],
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 'USER',
          child: Row(
            children: [
              Icon(Icons.person, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text('User'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'ADMIN',
          child: Row(
            children: [
              Icon(Icons.shield, size: 18, color: Colors.orange),
              SizedBox(width: 8),
              Text('Admin'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'ADMINTOUR',
          child: Row(
            children: [
              Icon(Icons.tour, size: 18, color: Colors.green),
              SizedBox(width: 8),
              Text('Admin Tour'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'ADMINHOTEL',
          child: Row(
            children: [
              Icon(Icons.hotel, size: 18, color: Colors.purple),
              SizedBox(width: 8),
              Text('Admin Hotel'),
            ],
          ),
        ),
      ],
      onChanged: (v) => setState(() => _selectedRole = v!),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Giới tính',
        prefixIcon: Icon(Icons.wc_rounded, color: Colors.blue[700]),
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
      items:
          _genders.map((gender) {
            return DropdownMenuItem(value: gender, child: Text(gender));
          }).toList(),
      onChanged: (v) => setState(() => _selectedGender = v),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Ngày sinh',
          prefixIcon: Icon(Icons.cake_outlined, color: Colors.blue[700]),
          suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
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
        child: Text(
          _selectedDate != null
              ? "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}"
              : 'Chọn ngày sinh',
          style: TextStyle(
            color: _selectedDate != null ? Colors.black87 : Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ),
    );
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
                  'Tạo mới',
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
