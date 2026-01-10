import 'package:flutter/material.dart';

import 'package:smart_travel/injection_container.dart' as di;

import '../../../data/models/comparison/comparison_models.dart';
import '../../../domain/repositories/comparison_repository.dart';
import '../../theme/app_colors.dart';

enum ComparisonType { tour, hotel }

class ComparisonResultScreen extends StatelessWidget {
  final int id1;
  final int id2;
  final ComparisonType type;

  const ComparisonResultScreen({
    Key? key,
    required this.id1,
    required this.id2,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(type == ComparisonType.tour ? "So sánh Tour" : "So sánh Khách sạn"),
          backgroundColor: AppColors.primary
      ),
      body: FutureBuilder(
        // Gọi API tương ứng dựa vào type
        future: type == ComparisonType.tour
            ? di.sl<ComparisonRepository>().compareTours(id1, id2)
            : di.sl<ComparisonRepository>().compareHotels(id1, id2),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (!snapshot.hasData) return const SizedBox();

          // Xử lý hiển thị dựa trên kiểu dữ liệu trả về
          if (snapshot.data is ComparisonResponse<TourComparisonModel>) {
            final data = snapshot.data as ComparisonResponse<TourComparisonModel>;
            return _buildBody(data.item1, data.item2, _buildTourColumn);
          } else {
            final data = snapshot.data as ComparisonResponse<HotelComparisonModel>;
            return _buildBody(data.item1, data.item2, _buildHotelColumn);
          }
        },
      ),
    );
  }

  Widget _buildBody<T>(T item1, T item2, Widget Function(T, bool) builder) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: builder(item1, true)),
          const SizedBox(width: 10),
          Expanded(child: builder(item2, false)),
        ],
      ),
    );
  }

  // --- UI CHO TOUR ---
  Widget _buildTourColumn(TourComparisonModel item, bool isLeft) {
    return _buildCard(
        isLeft,
        item.imageUrl,
        item.name,
        "${item.price} VND",
        [
          _buildInfoRow(Icons.calendar_today, "${item.durationDays}N ${item.durationNights}Đ"),
          _buildInfoRow(Icons.star, "${item.rating} sao"),
          const Divider(),
          const Text("Bao gồm:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ...item.included.map((e) => Text("• $e", style: const TextStyle(fontSize: 11, color: Colors.green))),
        ]
    );
  }

  // --- UI CHO HOTEL ---
  Widget _buildHotelColumn(HotelComparisonModel item, bool isLeft) {
    return _buildCard(
        isLeft,
        item.imageUrl,
        item.name,
        "${item.pricePerNight} VND/đêm",
        [
          _buildInfoRow(Icons.location_on, item.address),
          _buildInfoRow(Icons.star, "${item.stars} sao (${item.rating})"),
          _buildInfoRow(Icons.meeting_room, "${item.totalRooms} phòng"),
          const Divider(),
          const Text("Tiện ích:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ...item.amenities.map((e) => Text("• $e", style: const TextStyle(fontSize: 11, color: Colors.blue))),
        ]
    );
  }

  // --- UI CHUNG ---
  Widget _buildCard(bool isLeft, String? img, String name, String price, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isLeft ? Colors.blue.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Image.network(img ?? "https://via.placeholder.com/150", height: 100, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
          const Divider(),
          Text(price, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...children
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}