import 'package:flutter/material.dart';
import 'package:smart_travel/data/repositories/firebase_group_repository.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/entities/group.dart.dart';
import 'package:smart_travel/presentation/screens/chat/group_chat_screen.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

class ShareToGroupScreen extends StatefulWidget {
  final DestinationEntity? destination;
  final String? imageUrl;
  final String? priceText;
  final String? currentUserId;
  final String? currentUserName;
  final String? currentUserAvatar;


  const ShareToGroupScreen({
    Key? key,
    this.destination,
    this.imageUrl,
    this.priceText,
    this.currentUserId,
    this.currentUserName,
    this.currentUserAvatar,
  }) : super(key: key);

  @override
  State<ShareToGroupScreen> createState() => _ShareToGroupScreenState();
}

class _ShareToGroupScreenState extends State<ShareToGroupScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseGroupRepository _repository = FirebaseGroupRepository();
  String _searchQuery = '';
  List<GroupEntity> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadGroups() {
    if (widget.currentUserId == null) return;
    _repository.getUserGroups(widget.currentUserId!).listen(
          (groups) {
        if (!mounted) return;
        setState(() {
          _groups = groups;
          _isLoading = false;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isLoading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chia sẻ địa điểm',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Preview địa điểm đang chọn
          _buildDestinationCard(),

          // 2. Thanh tìm kiếm
          _buildSearchBar(),

          // 3. Nút Tạo/Tham gia nhóm nhanh
          _buildQuickActions(),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 32, thickness: 1),
          ),

          // 4. Danh sách nhóm (Dùng Expanded để cuộn mượt mà)
          Expanded(
            child: _buildGroupsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard() {
    if (widget.destination == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.imageUrl ?? '',
              width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60, height: 60, color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.destination!.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.priceText ?? 'Miễn phí',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm nhóm...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(child: _actionBtn(Icons.add_box_outlined, "Tạo nhóm", Colors.blue, () => _showCreateGroupDialog())),
          const SizedBox(width: 12),
          Expanded(child: _actionBtn(Icons.group_add_outlined, "Tham gia", Colors.green, () => _showJoinGroupDialog())),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final filtered = _groups.where((g) => g.name.toLowerCase().contains(_searchQuery)).toList();

    if (filtered.isEmpty) {
      return Center(child: Text('Không tìm thấy nhóm nào', style: TextStyle(color: Colors.grey[400])));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final group = filtered[index];
        return _buildGroupItem(group);
      },
    );
  }

  Widget _buildGroupItem(GroupEntity group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: group.avatar != null ? NetworkImage(group.avatar!) : null,
          child: group.avatar == null ? Text(group.name[0]) : null,
        ),
        title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${group.memberIds.length} thành viên'),
        trailing: IconButton(
          icon: Icon(Icons.send_rounded, color: AppColors.primary),
          // Nhấn icon: Gửi địa điểm rồi mới vào Chat
          onPressed: () => _shareAndGoToChat(group),
        ),
        // Nhấn vào item: Chỉ đi tới Chat để xem
        onTap: () => _navigateToChat(group),
      ),
    );
  }
  void _navigateToChat(GroupEntity group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatScreen(
          groupId: group.id,
          currentUserId: widget.currentUserId!,
          currentUserName: widget.currentUserName!,
          currentUserAvatar: widget.currentUserAvatar,
        ),
      ),
    );
  }

  Future<void> _shareAndGoToChat(GroupEntity group) async {
    try {
      await _repository.shareDestination(
        groupId: group.id,
        senderId: widget.currentUserId!,
        senderName: widget.currentUserName!,
        senderAvatar: widget.currentUserAvatar,
        destinationData: {
          'destination_id': widget.destination?.id.toString(),
          'name': widget.destination?.name,
          'image_url': widget.imageUrl,
          'price': widget.priceText,
          'lat': widget.destination?.latitude,
          'lng':widget.destination?.longitude,
        },
      );
      _showToast('Đã chia sẻ vào nhóm ${group.name}', Colors.green);
      if (!mounted) return;
      _navigateToChat(group);

    } catch (e) {
      _showToast(
        'Lỗi chia sẻ: ${e.toString().replaceFirst('Exception: ', '')}',
        Colors.red,
      );    }
  }

  void _showCreateGroupDialog() {
    final controller = TextEditingController();
    String? errorText;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder( // Sử dụng StatefulBuilder để update UI trong dialog
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Tạo nhóm mới'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Tên nhóm',
                    errorText: errorText, // Hiển thị lỗi tại đây
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  if (controller.text.trim().isEmpty) {
                    setDialogState(() => errorText = 'Tên nhóm không được để trống');
                    return;
                  }

                  setDialogState(() => isSubmitting = true);
                  try {
                    await _repository.createGroup(
                        name: controller.text.trim(),
                        creatorId: widget.currentUserId!
                    );
                    Navigator.pop(ctx);
                    _showToast('Tạo nhóm thành công', Colors.green);
                  } catch (e) {
                    setDialogState(() {
                      isSubmitting = false;
                      errorText = 'Lỗi: ${e.toString()}';
                    });
                  }
                },
                child: isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Tạo'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showJoinGroupDialog() {
    final controller = TextEditingController();
    String? errorText;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Tham gia bằng mã'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Nhập mã mời (8 ký tự)',
                errorText: errorText,
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  final code = controller.text.trim().toUpperCase();
                  if (code.isEmpty) {
                    setDialogState(() => errorText = 'Vui lòng nhập mã');
                    return;
                  }

                  setDialogState(() => isSubmitting = true);
                  try {
                    final group = await _repository.findGroupByInviteCode(code);
                    if (group != null) {
                      await _repository.joinGroup(group.id, widget.currentUserId!);
                      Navigator.pop(ctx);
                      _showToast('Đã tham gia nhóm ${group.name}', Colors.green);
                    } else {
                      setDialogState(() {
                        isSubmitting = false;
                        errorText = 'Mã mời không tồn tại';
                      });
                    }
                  } catch (e) {
                    setDialogState(() {
                      isSubmitting = false;
                      errorText = 'Lỗi kết nối';
                    });
                  }
                },
                child: isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Tham gia'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}