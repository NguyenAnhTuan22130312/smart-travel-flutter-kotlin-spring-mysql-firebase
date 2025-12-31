import 'package:flutter/material.dart';
import 'package:smart_travel/domain/entities/hotel.dart';

class HotelInfoSection extends StatelessWidget {
  final Hotel hotel;
  final double displayPrice;
  final Animation<double> fadeAnimation;

  const HotelInfoSection({
    super.key,
    required this.hotel,
    required this.displayPrice,
    required this.fadeAnimation,
  });

  // --- KHAI BÁO MÀU SẮC (CẤU HÌNH UI) ---
  static const Color primaryColor = Color(0xFF2DBBAA);
  static const Color secondaryPastel = Color(0xFFE6FAF7);
  static const Color textDark = Color(0xFF1F2937);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hotel.name ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: textDark,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                ...List.generate(
                  hotel.starRating ?? 0,
                  (_) => const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFBBF24),
                    size: 18,
                  ),
                ),
                if ((hotel.starRating ?? 0) > 0) const SizedBox(width: 6),
                Text(
                  '${hotel.averageRating?.toStringAsFixed(1) ?? '0.0'} (${hotel.reviewCount ?? 0} đánh giá)',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              hotel.description ?? 'Không có mô tả',
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: secondaryPastel,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Text(
                    "Giá chỉ từ: ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_formatPrice(hotel.pricePerNight ?? 0)}đ / đêm',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }
}
