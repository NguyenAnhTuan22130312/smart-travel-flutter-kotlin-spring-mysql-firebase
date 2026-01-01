  import 'dart:convert';

import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
  import 'package:smart_travel/data/models/tour/admin_tour_model.dart';
  import 'package:smart_travel/domain/entities/tour.dart';
  import 'package:smart_travel/presentation/blocs/adminTour/tour_bloc.dart';
  import 'package:smart_travel/presentation/blocs/adminTour/tour_event.dart';
  import 'package:smart_travel/presentation/blocs/adminTour/tour_state.dart';
  import 'package:smart_travel/presentation/blocs/adminTour/tour_detail_bloc.dart';
  import 'package:smart_travel/presentation/blocs/adminTour/tour_detail_event.dart';
  import 'package:smart_travel/presentation/blocs/adminTour/tour_detail_state.dart';
import 'package:smart_travel/presentation/screens/admin/tour/tour_create_model.dart';
  import 'package:smart_travel/presentation/screens/admin/tour/tour_edit_modal.dart';
  import 'package:smart_travel/presentation/theme/app_colors.dart';
  
  class AdminTourManagementScreen extends StatefulWidget {
    const AdminTourManagementScreen({super.key});
  
    @override
    State<AdminTourManagementScreen> createState() =>
        _AdminTourManagementScreenState();
  }

  class _EditTourDialogBody extends StatelessWidget {
    const _EditTourDialogBody();

    @override
    Widget build(BuildContext context) {
      return BlocListener<AdminTourDetailBloc, AdminTourDetailState>(
        listener: (context, state) {
          if (state is AdminTourUpdateSuccess) {
            // pop modal và trả true về parent
            Navigator.pop(context, true);
          }

          if (state is AdminTourDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Cập nhật tour thất bại')),
            );
          }
        },
        child: BlocBuilder<AdminTourDetailBloc, AdminTourDetailState>(
          builder: (context, state) {
            if (state is AdminTourDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdminTourDetailLoaded) {
              return AdminTourUpdateModal(
                tour: state.tour,
              );
            }

            if (state is AdminTourDetailError) {
              return AlertDialog(
                content: Text(state.message ?? 'Lỗi tải tour'),
              );
            }

            return const SizedBox();
          },
        ),
      );
    }
  }

  
  class _AdminTourManagementScreenState
      extends State<AdminTourManagementScreen> {
    final TextEditingController _searchController = TextEditingController();
    String _statusFilter = 'all';
  
    @override
    void initState() {
      super.initState();
      context.read<AdminTourBloc>().add(LoadAdminTours());
    }
  
    // ============================ UI ============================
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xffF6F7FB),
        appBar: AppBar(
          elevation: 0,
          title: const Text('Quản lý Tour'),
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: AppColors.mainGradient),
          ),
        ),
        body: Column(
          children: [
            _buildSearch(),
            _buildStatusFilter(),
            Expanded(child: _buildTourList()),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.green,
          icon: const Icon(Icons.add),
          label: const Text('Thêm'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => BlocProvider.value(
                value: context.read<AdminTourBloc>(),
                child: const CreateTourModal(),
              ),
            );
          },
        ),
      );
    }
  
  
    // ============================ SEARCH ============================
  
    Widget _buildSearch() {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Tìm tour...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      );
    }
  
    // ============================ FILTER ============================
  
    Widget _buildStatusFilter() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _buildChip('Tất cả', 'all'),
            _buildChip('Hoạt động', 'active'),
            _buildChip('Ngưng', 'inactive'),
          ],
        ),
      );
    }
  
    Widget _buildChip(String label, String value) {
      final selected = _statusFilter == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          selectedColor: AppColors.green,
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
          onSelected: (_) => setState(() => _statusFilter = value),
        ),
      );
    }
  
    // ============================ LIST ============================

    Widget _buildTourList() {
      return BlocConsumer<AdminTourBloc, AdminTourState>(
        listener: (context, state) {
          if (state is AdminTourDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã xoá tour thành công!')),
            );
          }

          if (state is AdminTourDeleteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state is AdminTourError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminTourLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminTourLoaded) {
            final tours = state.tours.where((t) {
              final matchSearch = t.name
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase());

              final matchStatus =
                  _statusFilter == 'all' ||
                      (_statusFilter == 'active' && t.isActive) ||
                      (_statusFilter == 'inactive' && !t.isActive);

              return matchSearch && matchStatus;
            }).toList();

            if (tours.isEmpty) {
              return const Center(child: Text('Không có tour'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: tours.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _buildTourCard(tours[i]),
            );
          }

          return const SizedBox();
        },
      );
    }
  
    // ============================ CARD ============================
  
    Widget _buildTourCard(AdminTourModel tourModel) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: tourModel.image != null && tourModel.image!.isNotEmpty
                ? Image.network(
              tourModel.image!,
              width: 55,
              height: 55,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _defaultImage(55),
            )
                : _defaultImage(55),
          ),
          title: Text(
            tourModel.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Điểm đến: ${tourModel.destinationName}'),
              Text(
                'Giá: ${tourModel.pricePerPerson} đ',
                style: const TextStyle(color: Colors.orange),
              ),
              Text(
                tourModel.isActive ? 'Hoạt động' : 'Ngưng hoạt động',
                style: TextStyle(
                  color: tourModel.isActive ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _openEditTourModal(tourModel.id);
              }
              if (value == 'delete') {
                _confirmDeleteTour(
                  context: context,
                  tourId: tourModel.id,
                  tourName: tourModel.name,
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Sửa'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Xoá'),
                  ],
                ),
              ),
            ],
          ),
  
          // ===== TAP TO DETAIL =====
          onTap: () {
            context
                .read<AdminTourDetailBloc>()
                .add(LoadAdminTourDetail(tourModel.id));
  
            _openTourDetail();
          },
        ),
      );
    }
  
    Widget _statusBadge(bool isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green.withOpacity(0.15)
              : Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isActive ? 'Hoạt động' : 'Ngưng',
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  
    // ============================ DETAIL ============================
  
    Future<void> _openTourDetail() async {
      final detailBloc = context.read<AdminTourDetailBloc>();
  
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) {
          return BlocProvider.value(
            value: detailBloc, // ⭐ QUAN TRỌNG: truyền bloc vào bottom sheet
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              minChildSize: 0.6,
              maxChildSize: 0.95,
              builder: (_, controller) {
                return BlocBuilder<AdminTourDetailBloc, AdminTourDetailState>(
                  builder: (context, state) {
                    if (state is AdminTourDetailLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
  
                    if (state is AdminTourDetailError) {
                      return Center(child: Text(state.message));
                    }
  
                    if (state is! AdminTourDetailLoaded) {
                      return const SizedBox();
                    }
  
                    final tour = state.tour;
  
                    return SingleChildScrollView(
                      controller: controller,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
  
                          // ===== DRAG HANDLE =====
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
  
                          const SizedBox(height: 12),
  
                          // ===== IMAGE =====
                          tour.image != null && tour.image!.isNotEmpty
                              ? Image.network(
                            tour.image!,
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                              : _defaultImage(double.infinity),
  
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ===== NAME =====
                                Text(
                                  tour.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
  
                                const SizedBox(height: 12),
                                const Text(
                                  'Thông tin tour',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // ===== INFO =====
                                _detailRow('Điểm đến', tour.destinationName),
                                _detailRow('Giá', '${tour.pricePerPerson} đ'),
                                _detailRow(
                                  'Thời gian',
                                  '${tour.durationDays}N${tour.durationNights}Đ',
                                ),
                                _detailRow(
                                  'Số khách',
                                  tour.maxPeople.toString(),
                                ),
                                _detailRow(
                                  'Lượt đặt',
                                  tour.bookingCount.toString(),
                                ),
  
                                const SizedBox(height: 16),
  
                                // ===== DESCRIPTION =====
                                if (tour.description != null &&
                                    tour.description!.isNotEmpty) ...[
                                  const Text(
                                    'Mô tả',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    parseDescription(tour.description!),
                                    style: const TextStyle(height: 1.4),
                                  )
                                ],

                                // ===== SCHEDULE =====
                                if (tour.schedules.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Lịch trình chi tiết',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
  
                                  ...tour.schedules.map(
                                        (s) => Container(
                                      margin: const EdgeInsets.only(bottom: 14),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // ===== DAY TITLE =====
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  size: 16, color: Colors.blue),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Ngày ${s.dayNumber}: ${s.title}',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
  
                                          const SizedBox(height: 10),
  
                                          // ===== ACTIVITIES =====
                                          if (s.activities != null && s.activities!.isNotEmpty) ...[
                                            const Row(
                                              children: [
                                                Icon(Icons.place, size: 16, color: Colors.green),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Hoạt động',
                                                  style: TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              s.activities!,
                                              style: const TextStyle(fontSize: 13, height: 1.4),
                                            ),
                                            const SizedBox(height: 8),
                                          ],
  
                                          // ===== ACCOMMODATION =====
                                          if (s.accommodation != null &&
                                              s.accommodation!.isNotEmpty) ...[
                                            Row(
                                              children: [
                                                const Icon(Icons.hotel,
                                                    size: 16, color: Colors.orange),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Lưu trú: ${s.accommodation}',
                                                    style: const TextStyle(fontSize: 13),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                          ],
  
                                          // ===== MEALS =====
                                          if (s.meals != null && s.meals!.isNotEmpty) ...[
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(Icons.restaurant,
                                                    size: 16, color: Colors.red),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Bữa ăn: ${s.meals!}',
                                                    style: const TextStyle(fontSize: 13),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),

                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Cập nhật'),
                                        onPressed: () {
                                          Navigator.pop(context); // đóng detail
                                          _openEditTourModal(tour.id);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        icon: const Icon(Icons.delete),
                                        label: const Text('Xoá'),
                                        onPressed: () {
                                          _confirmDeleteTour(
                                            context: context,
                                            tourId: tour.id,
                                            tourName: tour.name,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      );
    }

    void _openEditTourModal(int tourId) async {
      final detailBloc = context.read<AdminTourDetailBloc>();
      final adminTourBloc = context.read<AdminTourBloc>();

      // load detail
      detailBloc.add(LoadAdminTourDetail(tourId));

      final result = await showDialog<bool>(
        context: context,
        builder: (_) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: detailBloc),
              BlocProvider.value(value: adminTourBloc),
            ],
            child: const _EditTourDialogBody(),
          );
        },
      );

      // nếu update thành công thì reload list
      if (result == true) {
        context.read<AdminTourBloc>().add(LoadAdminTours());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật tour thành công')),
        );
      }
    }

    Widget _detailRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                '$label:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );
    }

    void _confirmDeleteTour({
      required BuildContext context,
      required int tourId,
      required String tourName,
    }) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Xoá tour'),
          content: Text('Bạn có chắc muốn xoá "$tourName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context); // đóng dialog
                context.read<AdminTourBloc>().add(
                  DeleteAdminTour(tourId),
                );
              },
              child: const Text('Xoá'),
            ),
          ],
        ),
      );
    }

  
    Widget _defaultImage(double size) {
      return Image.asset(
        'assets/images/img_4.png',
        width: size,
        height: size == double.infinity ? 240 : size,
        fit: BoxFit.cover,
      );
    }

    String parseDescription(String raw) {
      try {
        final doc = Document.fromJson(jsonDecode(raw));
        return doc.toPlainText().trim();
      } catch (_) {
        return raw;
      }
    }

  }
