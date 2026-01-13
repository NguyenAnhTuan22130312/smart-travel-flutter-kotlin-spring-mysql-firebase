import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/presentation/blocs/admin_audio/audio_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_audio/audio_event.dart';
import 'package:smart_travel/presentation/blocs/admin_audio/audio_state.dart';
import 'package:smart_travel/presentation/blocs/auth/auth_bloc.dart';
import 'package:smart_travel/presentation/blocs/auth/auth_state.dart';
import 'package:smart_travel/presentation/screens/admin/audio/audio_form_dialog.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

class AdminAudioScreen extends StatefulWidget {
  const AdminAudioScreen({Key? key}) : super(key: key);

  @override
  State<AdminAudioScreen> createState() => _AdminAudioScreenState();
}

class _AdminAudioScreenState extends State<AdminAudioScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DestinationEntity> _allDestinations = [];
  List<DestinationEntity> _filteredDestinations = [];

  @override
  void initState() {
    super.initState();
    if (_isAdmin()) {
      _loadData();
    }
  }

  void _loadData() {
    context.read<AudioBloc>().add(LoadAudioDestinations());
  }

  // --- 1. HÀM KIỂM TRA QUYỀN (Logic cốt lõi) ---
  bool _isAdmin() {
    final authState = context.read<AuthBloc>().state;
    String? role;

    // Lấy role từ AuthBloc
    if (authState is LoginSuccess) {
      role = authState.response.role;
    } else if (authState is AdminAuthenticated) {
      role = authState.role;
    }
    return role == "ADMIN";
  }

  // Hàm xử lý hành động an toàn
  void _handleAdminAction(VoidCallback action) {
    if (_isAdmin()) {
      action();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Từ chối truy cập',
            message: 'Chức năng này chỉ dành cho Quản trị viên hệ thống!',
            contentType: ContentType.warning,
          ),
        ),
      );
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filteredDestinations =
          _allDestinations
              .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  void _showEditModal(DestinationEntity destination) {
    final audioBloc = context.read<AudioBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return BlocProvider.value(
          value: audioBloc,
          child: AudioFormDialog(destination: destination),
        );
      },
    );
  }

  void _confirmDelete(DestinationEntity destination) {
    final audioBloc = context.read<AudioBloc>();

    showDialog(
      context: context,
      builder:
          (ctx) => BlocProvider.value(
            value: audioBloc,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.redAccent,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Xóa Audio?",
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        height: 1.5,
                        fontFamily: 'Roboto',
                      ),
                      children: [
                        const TextSpan(
                          text:
                              "Bạn có chắc chắn muốn xóa bài thuyết minh của địa điểm\n",
                        ),
                        TextSpan(
                          text: "\"${destination.name}\"",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textGray,
                          ),
                        ),
                        const TextSpan(text: " không?"),
                      ],
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: AppColors.textGray,
                        ),
                        child: const Text("Hủy bỏ"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          audioBloc.add(DeleteAudioScriptEvent(destination.id));
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Xóa ngay",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Kiểm tra quyền Admin ngay khi build
    final bool isAdmin = _isAdmin();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Quản Lý Audio',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
        elevation: 0,
        actions: [
          // Nếu không phải Admin thì ẩn nút Refresh hoặc disable nó
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _loadData,
              tooltip: "Làm mới",
            ),
        ],
      ),
      // 2. Logic hiển thị Body dựa trên quyền
      body:
          !isAdmin
              ? _buildAccessDeniedView() // Nếu không phải Admin -> Hiện màn hình chặn
              : BlocConsumer<AudioBloc, AudioState>(
                // Nếu là Admin -> Hiện danh sách bình thường
                listener: (context, state) {
                  if (state is AudioDestinationsLoaded) {
                    _allDestinations = state.destinations;
                    _filteredDestinations = state.destinations;
                    if (_searchController.text.isNotEmpty) {
                      _onSearch(_searchController.text);
                    }
                  }
                  if (state is AudioUpdateSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Thao tác thành công!"),
                        backgroundColor: AppColors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    _loadData();
                  }
                  if (state is AudioError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading =
                      state is AudioLoading && _allDestinations.isEmpty;

                  return Stack(
                    children: [
                      Column(
                        children: [
                          _buildSearchBar(),
                          Expanded(
                            child:
                                isLoading
                                    ? const Center() // Loading spinner ở stack dưới
                                    : _buildAudioList(_filteredDestinations),
                          ),
                        ],
                      ),
                      // Loading Overlay
                      if (state is AudioLoading)
                        Container(
                          color: Colors.black.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
    );
  }

  // --- Widget: Màn hình chặn truy cập (Access Denied) ---
  Widget _buildAccessDeniedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.gpp_bad_rounded,
              size: 80,
              color: Colors.red[300],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Hạn chế truy cập",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Bạn không có quyền quản lý Audio. Vui lòng liên hệ Admin để được hỗ trợ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. SEARCH BAR (Floating Style) ---
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF909090).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        style: const TextStyle(
          color: AppColors.textGray,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm địa điểm...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  // --- 2. LIST VIEW ---
  Widget _buildAudioList(List<DestinationEntity> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.graphic_eq_rounded,
                size: 60,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Không tìm thấy địa điểm",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildAudioCard(list[index]);
      },
    );
  }

  // --- 3. ITEM CARD (Đã làm đẹp) ---
  Widget _buildAudioCard(DestinationEntity item) {
    // Logic check audio có hay chưa
    final bool hasAudio =
        item.audioScript != null && item.audioScript!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withOpacity(0.06),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _showEditModal(item),
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primary.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 3.1. Icon/Ảnh đại diện bên trái
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    // Nếu có ảnh thật ở Entity thì dùng Image.network, tạm thời dùng Icon đẹp
                    color:
                        hasAudio
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      hasAudio
                          ? Icons.headphones_rounded
                          : Icons.mic_off_rounded,
                      color: hasAudio ? AppColors.primary : Colors.redAccent,
                      size: 32,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // 3.2. Nội dung chính
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên địa điểm
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3748),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Badge trạng thái
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              hasAudio ? Colors.green[50] : Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                hasAudio
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.orange.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasAudio
                                  ? Icons.check_circle_rounded
                                  : Icons.pending_rounded,
                              size: 14,
                              color:
                                  hasAudio
                                      ? Colors.green[700]
                                      : Colors.orange[800],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasAudio ? "Đã có Audio" : "Chưa cập nhật",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color:
                                    hasAudio
                                        ? Colors.green[700]
                                        : Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 3.3. Cột Action Buttons
                const SizedBox(width: 8),
                Column(
                  children: [
                    // Nút Edit / Add
                    _buildActionButton(
                      icon:
                          hasAudio
                              ? Icons.edit_note_rounded
                              : Icons.add_rounded,
                      color: hasAudio ? Colors.blueAccent : Colors.white,
                      bgColor:
                          hasAudio
                              ? Colors.blue.withOpacity(0.1)
                              : AppColors.primary,
                      onTap: () => _showEditModal(item),
                    ),

                    // Nút Xóa (Chỉ hiện khi có audio)
                    if (hasAudio) ...[
                      const SizedBox(height: 10),
                      _buildActionButton(
                        icon: Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        bgColor: Colors.red.withOpacity(0.1),
                        onTap: () => _confirmDelete(item),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget con: Nút hành động nhỏ gọn
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow:
              bgColor == AppColors.primary
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
