import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/presentation/blocs/admin_audio/audio_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_audio/audio_event.dart';
import 'package:smart_travel/presentation/blocs/admin_audio/audio_state.dart';
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
    _loadData();
  }

  void _loadData() {
    context.read<AudioBloc>().add(LoadAudioDestinations());
  }

  void _onSearch(String query) {
    setState(() {
      _filteredDestinations = _allDestinations
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Quản Lý Thuyết Minh Audio',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.mainGradient)),
      ),
      body: BlocConsumer<AudioBloc, AudioState>(
        listener: (context, state) {
          if (state is AudioDestinationsLoaded) {
            _allDestinations = state.destinations;
            _filteredDestinations = state.destinations;
          }
          if (state is AudioUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Thao tác thành công!"), backgroundColor: AppColors.green),
            );
            _loadData();
          }
          if (state is AudioError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildHeaderActions(),
              Expanded(
                child: (state is AudioLoading && _allDestinations.isEmpty)
                    ? const Center(child: CircularProgressIndicator())
                    : _buildAudioTable(_filteredDestinations),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Tìm địa điểm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadData,
          )
        ],
      ),
    );
  }

  Widget _buildAudioTable(List<DestinationEntity> list) {
    if (list.isEmpty) return const Center(child: Text("Không tìm thấy địa điểm."));

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.1)),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('ĐỊA ĐIỂM')),
            DataColumn(label: Text('TRẠNG THÁI')),
            DataColumn(label: Text('HÀNH ĐỘNG')),
          ],
          rows: list.map((item) {
            final bool hasAudio = item.audioScript != null && item.audioScript!.isNotEmpty;

            return DataRow(cells: [
              DataCell(Text("#${item.id}")),
              DataCell(SizedBox(width: 200, child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasAudio ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hasAudio ? "Hoàn thành" : "Chưa có",
                    style: TextStyle(
                        color: hasAudio ? Colors.green[700] : Colors.red[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                          hasAudio ? Icons.edit_note : Icons.add_circle_outline,
                          color: hasAudio ? AppColors.secondary : Colors.blue
                      ),
                      tooltip: hasAudio ? "Chỉnh sửa audio" : "Thêm audio mới",
                      onPressed: () => _showEditModal(item),
                    ),
                    if (hasAudio)
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                        tooltip: "Xóa audio",
                        onPressed: () => _confirmDelete(item),
                      ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  // Cập nhật hàm xóa để truyền Bloc đúng context
  void _confirmDelete(DestinationEntity destination) {
    // 1. Lấy tham chiếu đến Bloc từ context của màn hình chính
    final audioBloc = context.read<AudioBloc>();

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: audioBloc, // Truyền Bloc hiện tại vào Dialog
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Xác nhận xóa"),
          content: Text("Bạn có chắc chắn muốn xóa audio thuyết minh của ${destination.name}?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Hủy")
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              onPressed: () {
                audioBloc.add(DeleteAudioScriptEvent(destination.id));
                Navigator.pop(ctx); // Đóng dialog
              },
              child: const Text("Xóa", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}