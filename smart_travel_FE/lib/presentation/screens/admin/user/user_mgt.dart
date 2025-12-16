import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_event.dart';
import 'package:smart_travel/presentation/blocs/admin_user/admin_user_state.dart';
import 'package:smart_travel/presentation/screens/admin/user/user_create_modal.dart';
import 'package:smart_travel/presentation/screens/admin/user/user_detail_modal.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSortBy = 'createdAt';
  String _currentSortDirection = 'DESC';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    context.read<AdminUserBloc>().add(const LoadUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _showUserDetail(dynamic user) {
    final bloc = context.read<AdminUserBloc>();
    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: bloc,
            child: UserDetailModal(user: user),
          ),
    );
  }

  void _onSearch(String value) {
    // Cancel previous timer if exists
    _debounceTimer?.cancel();

    // Create new timer that waits 500ms before calling API
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      context.read<AdminUserBloc>().add(SearchUsers(value));
    });
  }

  void _onSortChange(String? sortBy) {
    if (sortBy != null) {
      setState(() {
        _currentSortBy = sortBy;
      });
      context.read<AdminUserBloc>().add(
        ChangeSort(sortBy: sortBy, sortDirection: _currentSortDirection),
      );
    }
  }

  void _toggleSortDirection() {
    setState(() {
      _currentSortDirection = _currentSortDirection == 'ASC' ? 'DESC' : 'ASC';
    });
    context.read<AdminUserBloc>().add(
      ChangeSort(sortBy: _currentSortBy, sortDirection: _currentSortDirection),
    );
  }

  void _showCreateUserModal() {
    final bloc = context.read<AdminUserBloc>();
    showDialog(
      context: context,
      builder:
          (dialogContext) =>
              BlocProvider.value(value: bloc, child: const UserCreateModal()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản Lý Người Dùng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.mainGradient),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateUserModal,
        icon: const Icon(Icons.person_add),
        label: const Text('Thêm User'),
        backgroundColor: Colors.blue,
      ),
      body: BlocBuilder<AdminUserBloc, AdminUserState>(
        builder: (context, state) {
          if (state is AdminUserLoading) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/travel_is_fun.json',
                width: 150,
              ),
            );
          }

          if (state is AdminUserError) {
            return _buildErrorState(state);
          }

          if (state is AdminUserLoaded) {
            return _buildBodyContent(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBodyContent(AdminUserLoaded state) {
    final users = state.userResponse.content;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          _buildSearchAndFilter(),
          const SizedBox(height: 16),
          _buildRoleFilterChips(state),
          const SizedBox(height: 12),
          _buildStatistics(state),
          const SizedBox(height: 16),
          Expanded(
            child:
                state.isRefreshing
                    ? _buildListLoadingIndicator() // Show loading only in list area
                    : users.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                      itemCount: users.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder:
                          (context, index) => _buildUserCard(users[index]),
                    ),
          ),
          if (state.userResponse.totalPages > 1)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildPagination(state),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChips(AdminUserLoaded state) {
    final currentRole = state.currentRoleFilter;

    return Row(
      children: [
        _buildFilterChip(
          label: 'Tất cả',
          isSelected: currentRole == null,
          onTap:
              () => context.read<AdminUserBloc>().add(const FilterRole(null)),
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          label: 'User',
          isSelected: currentRole == 'USER',
          onTap:
              () => context.read<AdminUserBloc>().add(const FilterRole('USER')),
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          label: 'Admin',
          isSelected: currentRole == 'ADMIN',
          onTap:
              () =>
                  context.read<AdminUserBloc>().add(const FilterRole('ADMIN')),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildListLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/travel_is_fun.json', width: 150),
          const SizedBox(height: 16),
          Text(
            'Đang tải...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: const InputDecoration(
                hintText: 'Tìm theo tên, email, SĐT...',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: _currentSortBy,
            underline: const SizedBox(),
            icon: const Icon(Icons.sort, color: Colors.grey),
            items: const [
              DropdownMenuItem(value: 'createdAt', child: Text('Ngày tạo')),
              DropdownMenuItem(value: 'email', child: Text('Email')),
              DropdownMenuItem(value: 'fullName', child: Text('Tên')),
              DropdownMenuItem(value: 'role', child: Text('Vai trò')),
            ],
            onChanged: _onSortChange,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _currentSortDirection == 'ASC'
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: Colors.grey,
            ),
            onPressed: _toggleSortDirection,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(AdminUserLoaded state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.people,
            'Tổng số',
            state.userResponse.totalElements.toString(),
            Colors.blue,
          ),
          Container(width: 1, height: 30, color: Colors.blue[200]),
          _buildStatItem(
            Icons.description,
            'Trang',
            '${state.userResponse.currentPage + 1}/${state.userResponse.totalPages}',
            Colors.orange,
          ),
          Container(width: 1, height: 30, color: Colors.blue[200]),
          _buildStatItem(
            Icons.view_list,
            'Hiển thị',
            '${state.userResponse.content.length}',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserCard(dynamic user) {
    final isActive = user.isActive ?? true;
    final isAdmin = user.role.toUpperCase() == 'ADMIN';

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showUserDetail(user),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                    child:
                        user.avatarUrl == null
                            ? const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey,
                            )
                            : null,
                  ),
                  if (isActive)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildRoleBadge(isAdmin),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (user.phone != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.phone!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(user.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (user.emailVerified)
                          Row(
                            children: [
                              Icon(
                                Icons.verified,
                                size: 12,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Đã xác thực',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.red[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isAdmin ? Colors.red[200]! : Colors.blue[200]!,
        ),
      ),
      child: Text(
        isAdmin ? 'ADMIN' : 'USER',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isAdmin ? Colors.red[700] : Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy người dùng',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AdminUserError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(state.message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed:
                () => context.read<AdminUserBloc>().add(const LoadUsers()),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(AdminUserLoaded state) {
    final currentPage = state.userResponse.currentPage;
    final totalPages = state.userResponse.totalPages;
    final hasPrevious = state.userResponse.hasPrevious;
    final hasNext = state.userResponse.hasNext;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed:
              hasPrevious
                  ? () => context.read<AdminUserBloc>().add(
                    ChangePage(currentPage - 1),
                  )
                  : null,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${currentPage + 1} / $totalPages',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed:
              hasNext
                  ? () => context.read<AdminUserBloc>().add(
                    ChangePage(currentPage + 1),
                  )
                  : null,
        ),
      ],
    );
  }
}
