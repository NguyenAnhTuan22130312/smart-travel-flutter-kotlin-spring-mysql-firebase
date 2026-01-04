import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_event.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_state.dart';
import 'package:smart_travel/presentation/screens/admin/user/user_edit_modal.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/core/utils/admin_permission_helper.dart';

class UserDetailModal extends StatefulWidget {
  final dynamic user;

  const UserDetailModal({Key? key, required this.user}) : super(key: key);

  @override
  State<UserDetailModal> createState() => _UserDetailModalState();
}

class _UserDetailModalState extends State<UserDetailModal> {
  bool _canModify = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final canModify = await AdminPermissionHelper.canModifyUser(
      widget.user.role,
    );
    setState(() {
      _canModify = canModify;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Avatar
            _buildHeader(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Role
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.user.fullName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildRoleBadge(widget.user.role),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Status Badge
                      _buildStatusBadge(widget.user.isActive ?? true),

                      const SizedBox(height: 20),

                      // Level & Experience Section (NEW!)
                      if (widget.user.currentLevel != null ||
                          widget.user.experiencePoints != null)
                        _buildLevelSection(),

                      // Contact Information
                      _buildSectionCard(
                        icon: Icons.contacts_rounded,
                        title: 'Thông tin liên hệ',
                        color: Colors.blue,
                        children: [
                          _buildCopyableInfoRow(
                            Icons.email_rounded,
                            'Email',
                            widget.user.email,
                            context,
                          ),
                          if (widget.user.phone != null)
                            _buildCopyableInfoRow(
                              Icons.phone_rounded,
                              'Số điện thoại',
                              widget.user.phone!,
                              context,
                            ),
                        ],
                      ),

                      // Personal Information
                      if (widget.user.bio != null ||
                          widget.user.gender != null ||
                          widget.user.dateOfBirth != null)
                        _buildSectionCard(
                          icon: Icons.person_rounded,
                          title: 'Thông tin cá nhân',
                          color: Colors.purple,
                          children: [
                            if (widget.user.bio != null)
                              _buildInfoRow(
                                Icons.info_outline,
                                'Bio',
                                widget.user.bio!,
                              ),
                            if (widget.user.gender != null)
                              _buildInfoRow(
                                Icons.wc_rounded,
                                'Giới tính',
                                _formatGender(widget.user.gender!),
                              ),
                            if (widget.user.dateOfBirth != null)
                              _buildInfoRow(
                                Icons.cake_rounded,
                                'Ngày sinh',
                                _formatDateOnly(widget.user.dateOfBirth!),
                              ),
                          ],
                        ),

                      // Location Info
                      if (widget.user.address != null ||
                          widget.user.city != null ||
                          widget.user.country != null)
                        _buildSectionCard(
                          icon: Icons.location_on_rounded,
                          title: 'Địa chỉ',
                          color: Colors.green,
                          children: [
                            if (widget.user.address != null)
                              _buildInfoRow(
                                Icons.home_rounded,
                                'Địa chỉ',
                                widget.user.address!,
                              ),
                            if (widget.user.city != null)
                              _buildInfoRow(
                                Icons.location_city_rounded,
                                'Thành phố',
                                widget.user.city!,
                              ),
                            if (widget.user.country != null)
                              _buildInfoRow(
                                Icons.flag_rounded,
                                'Quốc gia',
                                widget.user.country!,
                              ),
                          ],
                        ),

                      // Account Information
                      _buildSectionCard(
                        icon: Icons.shield_rounded,
                        title: 'Thông tin tài khoản',
                        color: Colors.orange,
                        children: [
                          _buildInfoRow(
                            widget.user.emailVerified
                                ? Icons.verified_user_rounded
                                : Icons.cancel_rounded,
                            'Email đã xác thực',
                            widget.user.emailVerified ? 'Có' : 'Chưa',
                            valueColor:
                                widget.user.emailVerified
                                    ? Colors.green[700]
                                    : Colors.red[700],
                          ),
                          _buildInfoRow(
                            Icons.login_rounded,
                            'Loại tài khoản',
                            _formatAuthProvider(widget.user.authProvider),
                          ),
                          _buildInfoRow(
                            Icons.calendar_today_rounded,
                            'Ngày tạo',
                            _formatDate(widget.user.createdAt),
                          ),
                          _buildInfoRow(
                            Icons.update_rounded,
                            'Cập nhật lần cuối',
                            _formatDate(widget.user.updatedAt),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: AppColors.mainGradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                child:
                    widget.user.avatarUrl != null
                        ? ClipOval(
                          child: Image.network(
                            widget.user.avatarUrl!,
                            width: 106,
                            height: 106,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.person_rounded,
                                  size: 55,
                                  color: Colors.grey,
                                ),
                          ),
                        )
                        : const Icon(
                          Icons.person_rounded,
                          size: 55,
                          color: Colors.grey,
                        ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[50]!, Colors.orange[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.orange[700],
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cấp độ & Điểm kinh nghiệm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Level Display
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[100]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber[600],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cấp độ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.user.currentLevel ?? 'N/A',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Experience Points Display
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[100]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        color: Colors.orange[600],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Điểm kinh nghiệm',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.user.experiencePoints != null
                            ? '${widget.user.experiencePoints} XP'
                            : 'N/A',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.lerp(color, Colors.black, 0.3),
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableInfoRow(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy_rounded, size: 18, color: Colors.grey[600]),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã sao chép $label'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Sao chép',
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final roleUpper = role.toUpperCase();
    List<Color> gradientColors;
    IconData icon;

    switch (roleUpper) {
      case 'ADMIN':
        gradientColors = [Colors.red[400]!, Colors.red[600]!];
        icon = Icons.admin_panel_settings;
        break;
      case 'ADMINTOUR':
        gradientColors = [Colors.green[400]!, Colors.green[600]!];
        icon = Icons.tour;
        break;
      case 'ADMINHOTEL':
        gradientColors = [Colors.purple[400]!, Colors.purple[600]!];
        icon = Icons.hotel;
        break;
      default:
        gradientColors = [Colors.blue[400]!, Colors.blue[600]!];
        icon = Icons.person;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            roleUpper == 'ADMINTOUR'
                ? 'ADMIN TOUR'
                : roleUpper == 'ADMINHOTEL'
                ? 'ADMIN HOTEL'
                : roleUpper,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.green[200]! : Colors.red[200]!,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.green[500] : Colors.red[500],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? 'Đang hoạt động' : 'Đã khóa',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatDateOnly(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Nam';
      case 'female':
        return 'Nữ';
      case 'other':
        return 'Khác';
      default:
        return gender;
    }
  }

  String _formatAuthProvider(String provider) {
    switch (provider.toUpperCase()) {
      case 'LOCAL':
        return 'Tài khoản nội bộ';
      case 'GOOGLE':
        return 'Google';
      case 'FACEBOOK':
        return 'Facebook';
      default:
        return provider;
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    final isActive = widget.user.isActive ?? true;

    // Hide all buttons while checking permissions
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // If no modify permission, only show Close button
    if (!_canModify) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Đóng'),
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
      );
    }

    return BlocListener<AdminUserBloc, AdminUserState>(
      listener: (context, state) {
        if (state is AdminUserLockSuccess) {
          Navigator.pop(context);
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Thành công',
              message: state.message,
              contentType: ContentType.success,
            ),
          );
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
        if (state is AdminUserLockError) {
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Lỗi',
              message: state.message,
              contentType: ContentType.failure,
            ),
          );
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
        if (state is AdminUserUnlockSuccess) {
          Navigator.pop(context);
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Thành công',
              message: state.message,
              contentType: ContentType.success,
            ),
          );
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
        if (state is AdminUserUnlockError) {
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Lỗi',
              message: state.message,
              contentType: ContentType.failure,
            ),
          );
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final bloc = context.read<AdminUserBloc>();
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder:
                            (dialogContext) => BlocProvider.value(
                              value: bloc,
                              child: UserEditModal(user: widget.user),
                            ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Sửa'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.blue[700]!, width: 2),
                      foregroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isActive ? Colors.red : Colors.green)
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showLockUnlockConfirm(context, isActive);
                      },
                      icon: Icon(isActive ? Icons.lock : Icons.lock_open),
                      label: Text(isActive ? 'Khóa' : 'Mở khóa'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor:
                            isActive ? Colors.red[600] : Colors.green[600],
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Đóng'),
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
          ],
        ),
      ),
    );
  }

  void _showLockUnlockConfirm(BuildContext context, bool isActive) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(isActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản'),
            content: Text(
              isActive
                  ? 'Bạn có chắc muốn khóa tài khoản "${widget.user.fullName}" không?'
                  : 'Bạn có chắc muốn mở khóa tài khoản "${widget.user.fullName}" không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  if (isActive) {
                    context.read<AdminUserBloc>().add(LockUser(widget.user.id));
                  } else {
                    context.read<AdminUserBloc>().add(
                      UnlockUser(widget.user.id),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? Colors.red : Colors.green,
                ),
                child: Text(isActive ? 'Khóa' : 'Mở khóa'),
              ),
            ],
          ),
    );
  }
}
