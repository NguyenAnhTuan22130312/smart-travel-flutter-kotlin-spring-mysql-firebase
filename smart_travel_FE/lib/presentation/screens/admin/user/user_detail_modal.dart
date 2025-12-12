import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserDetailModal extends StatelessWidget {
  final dynamic user;

  const UserDetailModal({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Avatar
            _buildHeader(context),

            // Content
            Padding(
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
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildRoleBadge(user.role),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Status Badge
                  _buildStatusBadge(user.isActive ?? true),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Contact Information
                  _buildSectionTitle('Thông tin liên hệ'),
                  _buildInfoRow(Icons.email_outlined, 'Email', user.email),
                  if (user.phone != null)
                    _buildInfoRow(
                      Icons.phone_outlined,
                      'Số điện thoại',
                      user.phone!,
                    ),

                  const SizedBox(height: 16),

                  // Account Information
                  _buildSectionTitle('Thông tin tài khoản'),
                  _buildInfoRow(
                    Icons.verified_user_outlined,
                    'Email đã xác thực',
                    user.emailVerified ? 'Có' : 'Chưa',
                  ),
                  _buildInfoRow(
                    Icons.login_outlined,
                    'Loại tài khoản',
                    user.authProvider,
                  ),
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    'Ngày tạo',
                    _formatDate(user.createdAt),
                  ),
                  _buildInfoRow(
                    Icons.update_outlined,
                    'Cập nhật lần cuối',
                    _formatDate(user.updatedAt),
                  ),

                  // Additional Profile Info
                  if (user.bio != null ||
                      user.gender != null ||
                      user.dateOfBirth != null) ...[
                    const SizedBox(height: 16),
                    _buildSectionTitle('Thông tin cá nhân'),
                  ],

                  if (user.bio != null)
                    _buildInfoRow(Icons.info_outline, 'Bio', user.bio!),
                  if (user.gender != null)
                    _buildInfoRow(
                      Icons.person_outline,
                      'Giới tính',
                      user.gender!,
                    ),
                  if (user.dateOfBirth != null)
                    _buildInfoRow(
                      Icons.cake_outlined,
                      'Ngày sinh',
                      _formatDate(user.dateOfBirth!),
                    ),

                  // Location Info
                  if (user.address != null ||
                      user.city != null ||
                      user.country != null) ...[
                    const SizedBox(height: 16),
                    _buildSectionTitle('Địa chỉ'),
                  ],

                  if (user.address != null)
                    _buildInfoRow(
                      Icons.home_outlined,
                      'Địa chỉ',
                      user.address!,
                    ),
                  if (user.city != null)
                    _buildInfoRow(
                      Icons.location_city_outlined,
                      'Thành phố',
                      user.city!,
                    ),
                  if (user.country != null)
                    _buildInfoRow(
                      Icons.flag_outlined,
                      'Quốc gia',
                      user.country!,
                    ),

                  const SizedBox(height: 24),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Đóng'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child:
                  user.avatarUrl != null
                      ? ClipOval(
                        child: Image.network(
                          user.avatarUrl!,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              ),
                        ),
                      )
                      : const Icon(Icons.person, size: 50, color: Colors.grey),
            ),
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final isAdmin = role.toUpperCase() == 'ADMIN';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.red[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAdmin ? Colors.red[200]! : Colors.blue[200]!,
        ),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isAdmin ? Colors.red[700] : Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? Colors.green[200]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: isActive ? Colors.green[700] : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Đang hoạt động' : 'Không hoạt động',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.green[700] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
