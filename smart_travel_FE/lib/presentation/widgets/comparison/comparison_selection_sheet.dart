import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/comparison/comparison_bloc.dart';
import 'package:smart_travel/presentation/blocs/comparison/comparison_event.dart';
import 'package:smart_travel/presentation/blocs/comparison/comparison_state.dart';
import 'package:smart_travel/presentation/screens/comparison/comparison_result_screen.dart';

import 'package:smart_travel/injection_container.dart' as di;

import '../../theme/app_colors.dart';

class ComparisonSelectionSheet extends StatefulWidget {
  const ComparisonSelectionSheet({Key? key}) : super(key: key);

  @override
  State<ComparisonSelectionSheet> createState() => _ComparisonSelectionSheetState();
}

class _ComparisonSelectionSheetState extends State<ComparisonSelectionSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? selectedId1;
  int? selectedId2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedId1 = null;
          selectedId2 = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tạo Provider ở đỉnh
    return BlocProvider(
      create: (context) => di.sl<ComparisonBloc>()..add(LoadTourSelectionList()),

      // 2. QUAN TRỌNG: Dùng Builder để tạo context mới
      child: Builder(
          builder: (context) {
            // Từ đây trở xuống, biến 'context' này đã nhìn thấy ComparisonBloc
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    onTap: (index) {
                      // Sửa lỗi ở đây: context này bây giờ đã hợp lệ
                      final bloc = context.read<ComparisonBloc>();
                      if (index == 0) bloc.add(LoadTourSelectionList());
                      else bloc.add(LoadHotelSelectionList());
                    },
                    tabs: const [
                      Tab(text: "So sánh Tour"),
                      Tab(text: "So sánh Khách sạn"),
                    ],
                  ),

                  Expanded(
                    child: BlocBuilder<ComparisonBloc, ComparisonState>(
                      builder: (context, state) {
                        List<dynamic> tours = [];
                        List<dynamic> hotels = [];

                        if (state is ComparisonSelectionLoaded) {
                          tours = state.tours;
                          hotels = state.hotels;
                        }

                        return TabBarView(
                          controller: _tabController,
                          children: [
                            _buildSelectionForm("Tour", tours, state is ComparisonLoading, context),
                            _buildSelectionForm("Khách sạn", hotels, state is ComparisonLoading, context),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  // Truyền context vào đây để dùng khi Navigator push
  Widget _buildSelectionForm(String type, List<dynamic> items, bool isLoading, BuildContext context) {
    if (isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Chọn 2 $type để so sánh", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          _buildDropdown("Chọn $type thứ nhất", items, selectedId1, (val) => selectedId1 = val),
          const SizedBox(height: 16),

          const Center(child: CircleAvatar(backgroundColor: Colors.lightBlue, radius: 15, child: Text("VÀ", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 16),

          _buildDropdown("Chọn $type thứ hai", items, selectedId2, (val) => selectedId2 = val),

          const Spacer(),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (selectedId1 != null && selectedId2 != null) {
                bool isTour = _tabController.index == 0;
                Navigator.pop(context); // Đóng sheet
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ComparisonResultScreen(
                      id1: selectedId1!,
                      id2: selectedId2!,
                      type: isTour ? ComparisonType.tour : ComparisonType.hotel,
                    ))
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn đủ 2 mục!")));
              }
            },
            child: const Text("BẮT ĐẦU SO SÁNH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint, List<dynamic> items, int? currentValue, Function(int?) onChanged) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100]),
        child: const Text("Đang tải hoặc danh sách trống...", style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          hint: Text(hint),
          // Check an toàn để tránh crash nếu ID cũ không còn trong list mới
          value: items.any((e) {
            if (e is Map) return e['id'] == currentValue;
            return (e as dynamic).id == currentValue;
          }) ? currentValue : null,
          items: items.map((item) {
            int id;
            String name;

            if (item is Map) {
              id = item['id'];
              name = item['name'] ?? "Không tên";
            } else {
              dynamic objectItem = item;
              id = objectItem.id;
              name = objectItem.name;
            }

            return DropdownMenuItem<int>(
              value: id,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              onChanged(val);
            });
          },
        ),
      ),
    );
  }
}