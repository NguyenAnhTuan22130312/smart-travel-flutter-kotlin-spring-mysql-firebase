import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/params/TourFilterParams.dart';
import 'package:smart_travel/presentation/blocs/tour/tour_bloc.dart';
import 'package:smart_travel/presentation/blocs/tour/tour_event.dart';
import 'package:smart_travel/presentation/blocs/tour/tour_state.dart';
import 'package:smart_travel/presentation/screens/tour/tour_detail_screen.dart';
import 'package:smart_travel/presentation/widgets/tour/tour_card.dart';
import 'package:smart_travel/presentation/widgets/tour/tour_sort_button.dart';
import 'package:smart_travel/presentation/widgets/tour/tour_filter_button.dart';
// 1. IMPORT CÁC THÀNH PHẦN GIỐNG HOTEL
import 'package:smart_travel/presentation/widgets/common/bottom_navigation.dart';
import 'package:smart_travel/router/route_names.dart';
import '../../theme/app_colors.dart';

class TourListScreen extends StatefulWidget {
  const TourListScreen({super.key});

  @override
  State<TourListScreen> createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Thêm controller để cuộn trang

  int _selectedIndex = 2; // Index của Tour trong menu dưới
  String? sortValue = "popular_desc";
  double? minRating;
  double? minPrice, maxPrice;
  int? minDays, maxDays;

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // CẬP NHẬT: Thêm tham số page để phân trang
  void _loadTours({int page = 0}) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    final params = TourFilterParams(
      keyword: _searchCtrl.text.trim(),
      minPrice: minPrice?.toInt(),
      maxPrice: maxPrice?.toInt(),
      minDays: minDays,
      maxDays: maxDays,
      minRating: minRating,
      sort: sortValue,
      page: page, // Đảm bảo TourFilterParams của bạn có field này
    );

    context.read<TourBloc>().add(LoadToursEvent(params));
  }

  // 2. HÀM ĐIỀU HƯỚNG BOTTOM MENU (GIỐNG HOTEL)
  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0: Navigator.pushReplacementNamed(context, RouteNames.home); break;
      case 1: Navigator.pushReplacementNamed(context, RouteNames.explore); break;
      case 3: Navigator.pushReplacementNamed(context, RouteNames.hotelList); break;
      case 5: Navigator.pushReplacementNamed(context, RouteNames.profile); break;
    }
  }

  // 3. UI PHÂN TRANG (GIỐNG HOTEL)
  Widget _buildPaginationControls(int currentPage, int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 0 ? () => _loadTours(page: currentPage - 1) : null,
            icon: Icon(Icons.arrow_back_ios_rounded, size: 18,
                color: currentPage > 0 ? AppColors.primary : Colors.grey[300]),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(totalPages, (index) {
                final isSelected = index == currentPage;
                return GestureDetector(
                  onTap: () => isSelected ? null : _loadTours(page: index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 35, height: 35,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: Text("${index + 1}",
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          IconButton(
            onPressed: currentPage < totalPages - 1 ? () => _loadTours(page: currentPage + 1) : null,
            icon: Icon(Icons.arrow_forward_ios_rounded, size: 18,
                color: currentPage < totalPages - 1 ? AppColors.primary : Colors.grey[300]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
        title: const Text("Danh sách Tour",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Phần Search và Sort/Filter gom lại thành Header cố định
          _buildTopBar(),

          Expanded(
            child: BlocBuilder<TourBloc, TourState>(
              builder: (context, state) {
                if (state.loading) return const Center(child: CircularProgressIndicator());

                final tours = state.tours;
                if (tours.isEmpty) return const Center(child: Text("Không có tour nào"));

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: tours.length + 1, // Cộng 1 để hiện thanh phân trang ở cuối
                  itemBuilder: (context, index) {
                    if (index == tours.length) {
                      // HIỂN THỊ PHÂN TRANG (Lấy từ state của Bloc)
                      return _buildPaginationControls(state.currentPage ?? 0, state.totalPages ?? 1);
                    }

                    final t = tours[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TourCard(
                        tour: t,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TourDetailScreen(tourId: t.id!)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // 4. THÊM BOTTOM NAVIGATION (GIỐNG HOTEL)
      bottomNavigationBar: AppBottomNavigationWithIndicator(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  // TỔ CHỨC LẠI HEADER CHO GIỐNG HOTEL
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: "Tìm kiếm tour...",
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onSubmitted: (_) => _loadTours(),
          ),
          const SizedBox(height: 12),
          // Sort & Filter Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TourSortButton(
                sortValue: sortValue,
                onSelected: (v) {
                  setState(() => sortValue = v);
                  _loadTours();
                },
              ),
              TourFilterButton(onPressed: _openFilterSheet),
            ],
          ),
        ],
      ),
    );
  }


  // ===========================
  // FILTER BOTTOM SHEET
  // ===========================
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        double tempRating = minRating ?? 0;
        String? tempPrice;
        String? tempDays;

        return StatefulBuilder(
          builder: (context, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bộ lọc Tour",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // PRICE FILTER
                    const Text("Khoảng giá",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ...[
                      {"val": "under1", "label": "Dưới 1.000.000"},
                      {"val": "1to3", "label": "1.000.000 - 3.000.000"},
                      {"val": "3to5", "label": "3.000.000 - 5.000.000"},
                      {"val": "5to10", "label": "5.000.000 - 10.000.000"},
                      {"val": "over10", "label": "Trên 10.000.000"},
                    ].map((e) {
                      return RadioListTile(
                        value: e["val"],
                        groupValue: tempPrice,
                        title: Text(e["label"]!),
                        onChanged: (v) => setSheet(() => tempPrice = v),
                      );
                    }).toList(),

                    const SizedBox(height: 12),

                    // DAYS FILTER
                    const Text("Số ngày",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ...[
                      {"val": "1", "label": "1 ngày"},
                      {"val": "2", "label": "2 ngày"},
                      {"val": "3", "label": "3 ngày"},
                      {"val": "5", "label": "5 ngày"},
                      {"val": "7+", "label": "Trên 7 ngày"},
                    ].map((e) {
                      return RadioListTile(
                        value: e["val"],
                        groupValue: tempDays,
                        title: Text(e["label"]!),
                        onChanged: (v) => setSheet(() => tempDays = v),
                      );
                    }).toList(),

                    const SizedBox(height: 12),

                    // RATING FILTER
                    const Text("Rating tối thiểu",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Slider(
                      value: tempRating,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      activeColor: Colors.orange,
                      label: tempRating.toStringAsFixed(0),
                      onChanged: (v) => setSheet(() => tempRating = v),
                    ),

                    const SizedBox(height: 20),

                    // APPLY BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          // ---- APPLY PRICE ----
                          if (tempPrice == "under1") {
                            minPrice = 0;
                            maxPrice = 1000000;
                          } else if (tempPrice == "1to3") {
                            minPrice = 1000000;
                            maxPrice = 3000000;
                          } else if (tempPrice == "3to5") {
                            minPrice = 3000000;
                            maxPrice = 5000000;
                          } else if (tempPrice == "5to10") {
                            minPrice = 5000000;
                            maxPrice = 10000000;
                          } else if (tempPrice == "over10") {
                            minPrice = 10000000;
                            maxPrice = null;
                          }

                          // ---- APPLY DAYS ----
                          if (tempDays == "1") {
                            minDays = maxDays = 1;
                          } else if (tempDays == "2") {
                            minDays = maxDays = 2;
                          } else if (tempDays == "3") {
                            minDays = maxDays = 3;
                          } else if (tempDays == "5") {
                            minDays = maxDays = 5;
                          } else if (tempDays == "7+") {
                            minDays = 7;
                            maxDays = null;
                          }

                          minRating = tempRating;

                          Navigator.pop(context);
                          _loadTours();
                        },
                        child: const Text("Áp dụng",
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================
  // UI COMPONENTS
  // ===========================

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00AEEF), Color(0xFF2DBBAA)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Nút back
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 40,      // kích thước vòng tròn
                  height: 40,     // kích thước vòng tròn
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center, // icon luôn căn giữa
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "Danh sách Tour",
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: "Tìm kiếm tour...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (_) => _loadTours(),
      ),
    );
  }

  Widget _buildSortFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TourSortButton(
            sortValue: sortValue,
            onSelected: (v) {
              setState(() => sortValue = v);
              _loadTours();
            },
          ),
          TourFilterButton(onPressed: _openFilterSheet),
        ],
      ),
    );
  }
}
