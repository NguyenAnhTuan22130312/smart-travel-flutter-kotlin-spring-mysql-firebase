import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/injection_container.dart' as di;
import 'package:smart_travel/presentation/blocs/review/reviewhtd_bloc.dart'; // ← Sửa tên bloc
import 'package:smart_travel/presentation/blocs/review/reviewhtd_event.dart'; // ← Sửa event
import 'package:smart_travel/presentation/blocs/review/reviewhtd_state.dart'; // ← Sửa state
import 'package:smart_travel/presentation/theme/app_colors.dart';
import '../../screens/review/review_card.dart';
class ReviewListWidget extends StatefulWidget {
  final String type; // "HOTEL", "TOUR", "DESTINATION"
  final int serviceId;

  const ReviewListWidget({
    Key? key,
    required this.type,
    required this.serviceId,
  }) : super(key: key);

  @override
  State<ReviewListWidget> createState() => _ReviewListWidgetState();
}

class _ReviewListWidgetState extends State<ReviewListWidget> {
  int? selectedRating; // null = tất cả
  bool? hasImageFilter; // null = tất cả

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    context.read<ReviewHtdBloc>().add( // ← Sửa tên Bloc
      LoadReviewHtd( // ← Sửa tên Event
        type: widget.type,
        serviceId: widget.serviceId,
        rating: selectedRating,
        hasImage: hasImageFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // === FILTER BAR ===
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              // Filter sao
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  const Text("Đánh giá", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildRatingChip(null, "Tất cả"),
                          _buildRatingChip(5, "5 sao"),
                          _buildRatingChip(4, "4 sao"),
                          _buildRatingChip(3, "3 sao"),
                          _buildRatingChip(2, "2 sao"),
                          _buildRatingChip(1, "1 sao"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Filter ảnh
              Row(
                children: [
                  const Icon(Icons.photo_library, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text("Hình ảnh", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildImageFilterChip(null, "Tất cả"),
                          _buildImageFilterChip(true, "Có ảnh"),
                          _buildImageFilterChip(false, "Không có ảnh"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // === LIST REVIEW ===
        Expanded(
          child: BlocBuilder<ReviewHtdBloc, ReviewHtdState>( // ← Sửa Bloc + State
            builder: (context, state) {
              if (state is ReviewHtdLoading) { // ← Sửa state
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (state is ReviewHtdError) { // ← Sửa state
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReviews,
                        child: const Text("Thử lại"),
                      ),
                    ],
                  ),
                );
              }

              if (state is ReviewHtdLoaded) { // ← Sửa state
                if (state.reviews.isEmpty) {
                  return const Center(
                    child: Text("Chưa có đánh giá nào", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.reviews.length,
                  itemBuilder: (context, index) {
                    final review = state.reviews[index];
                    return ReviewCard(
                      userFullName: review.userFullName,
                      rating: review.rating,
                      comment: review.comment,
                      images: List<String>.from(review.images ?? []),
                      likesCount: review.likesCount,
                      createdAt: review.createdAt,
                    );
                  },
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRatingChip(int? rating, String label) {
    final isSelected = selectedRating == rating;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary.withOpacity(0.2),
        backgroundColor: Colors.grey[100],
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              selectedRating = rating;
            });
            _loadReviews();
          }
        },
      ),
    );
  }

  Widget _buildImageFilterChip(bool? hasImage, String label) {
    final isSelected = hasImageFilter == hasImage;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary.withOpacity(0.2),
        backgroundColor: Colors.grey[100],
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              hasImageFilter = hasImage;
            });
            _loadReviews();
          }
        },
      ),
    );
  }
}