import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_colors.dart';
import 'package:smart_travel/presentation/blocs/tour/tour_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/tour/tour_detail_event.dart';
import 'package:smart_travel/presentation/blocs/tour/tour_detail_state.dart';
import 'package:smart_travel/presentation/screens/booking/booking_screen.dart';
import 'package:smart_travel/presentation/screens/booking/booking_args.dart';


class TourDetailScreen extends StatefulWidget {
  final int tourId;

  const TourDetailScreen({super.key, required this.tourId});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  bool expand = false;

  @override
  void initState() {
    super.initState();
    context.read<TourDetailBloc>().add(LoadTourDetail(widget.tourId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TourDetailBloc, TourDetailState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.detail == null) {
            return const Center(child: Text("Không tìm thấy tour"));
          }

          final t = state.detail!;

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 80), // chừa chỗ cho nút
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 240,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(t.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        background: Image.network(
                          t.imageUrls.isNotEmpty ? t.imageUrls.first : "",
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.name,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Text("${t.durationDays} ngày ${t.durationNights} đêm",
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                            const SizedBox(height: 10),
                            Text("${t.pricePerPerson.toStringAsFixed(0)} đ/người",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                            const SizedBox(height: 20),
                            _buildSection("Giới thiệu", t.description ?? ""),
                            const SizedBox(height: 20),
                            _buildExpandableItinerary(t),
                            const SizedBox(height: 20),
                            _buildGallery(t.imageUrls),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // Nút đặt tour cố định dưới màn hình
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          // Truyền dữ liệu tour hiện tại vào BookingArgs
                          args: BookingArgs(
                            bookingType: 'TOUR', // Đánh dấu là đặt Tour
                            id: t.id,
                            name: t.name ?? "Tour du lịch",
                            price: t.pricePerPerson ?? 0.0,
                            imageUrl: (t.imageUrls != null && t.imageUrls!.isNotEmpty)
                                ? t.imageUrls!.first
                                : "",
                          ),
                        ),
                      ),
                    );

                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Color(0xFF2196F3),
                  ),
                  child: const Text(
                    "Đặt tour ngay",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(content, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
      ],
    );
  }

  Widget _buildExpandableItinerary(detail) {
    return ExpansionPanelList(
      expansionCallback: (_, isOpen) {
        setState(() => expand = !expand);
      },
      children: [
        ExpansionPanel(
          isExpanded: expand,
          headerBuilder: (_, __) => const Padding(
            padding: EdgeInsets.all(9),
            child: Text("Lịch trình chi tiết",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: Column(
            children: detail.schedules
                .map<Widget>((s) => ListTile(
              title: Text("Ngày ${s.dayNumber}: ${s.title}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (s.activities != null) Text("Hoạt động: ${s.activities}"),
                  if (s.meals != null) Text("Bữa ăn: ${s.meals}"),
                ],
              ),
            ))
                .toList(),
          ),
        )
      ],
    );
  }

  Widget _buildGallery(List<String> images) {
    if (images.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Hình ảnh",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(images[i],
                  width: 120,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(width: 120, height: 110, color: Colors.grey)),
            ),
          ),
        ),
      ],
    );
  }
}
