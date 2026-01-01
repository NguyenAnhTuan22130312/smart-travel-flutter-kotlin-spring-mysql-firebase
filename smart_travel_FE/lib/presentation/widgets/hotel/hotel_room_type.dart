import 'package:flutter/material.dart';
import 'package:smart_travel/domain/entities/room_type.dart';

class HotelRoomTypeWidget extends StatelessWidget {
  final List<RoomType> rooms;
  // Callback để báo cho màn hình cha biết phòng nào được chọn
  final Function(RoomType) onBook;

  const HotelRoomTypeWidget({
    super.key,
    required this.rooms,
    required this.onBook,
  });

  // --- KHAI BÁO MÀU SẮC ---
  static const Color primaryColor = Color(0xFF2DBBAA);
  static const Color secondaryPastel = Color(0xFFE6FAF7);
  static const Color textDark = Color(0xFF1F2937);

  @override
  Widget build(BuildContext context) {
    // ------------------------------
    // TRƯỜNG HỢP KHÔNG CÓ ROOM
    // ------------------------------
    if (rooms.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Chưa có loại phòng khả dụng',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // ------------------------------
    // TRƯỜNG HỢP CÓ DỮ LIỆU
    // ------------------------------
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ----------- TIÊU ĐỀ -----------
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Các loại phòng',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${rooms.length} lựa chọn cho bạn',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 16),

        // ----------- DANH SÁCH PHÒNG -----------
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            final bool isLast = index == rooms.length - 1;
            final bool isAvailable = (room.availableRooms ?? 0) > 0;

            return Container(
              margin: EdgeInsets.only(bottom: isLast ? 16 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----------- HEADER PHÒNG -----------
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.1),
                          primaryColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.hotel_rounded,
                            size: 26,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // ----------- TÊN PHÒNG + SỨC CHỨA -----------
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.name ?? 'Phòng tiêu chuẩn',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_rounded,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${room.capacity ?? 2} người',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ----------- TAG TRẠNG THÁI -----------
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? const Color(0xFF4CAF50)
                                : Colors.red[400],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isAvailable
                                ? 'Còn ${room.availableRooms}'
                                : 'Hết phòng',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ----------- THÔNG TIN CHI TIẾT -----------
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ----------- TIỆN NGHI -----------
                        if (room.amenities != null &&
                            room.amenities!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Tiện nghi',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: room.amenities!.take(4).map((a) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: primaryColor.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getAmenityIcon(a),
                                          size: 14,
                                          color: primaryColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          a,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),

                              if (room.amenities!.length > 4)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '+${room.amenities!.length - 4} tiện nghi khác',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                        const SizedBox(height: 16),

                        // ----------- GIÁ + NÚT CHỌN PHÒNG -----------
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Giá phòng',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _formatPrice(room.price ?? 0),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                            height: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Padding(
                                          padding: EdgeInsets.only(bottom: 2),
                                          child: Text(
                                            'đ/đêm',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              // BUTTON CHỌN PHÒNG (ĐÃ CẬP NHẬT LOGIC)
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: isAvailable
                                      ? () {
                                    // GỌI CALLBACK ĐỂ CHUYỂN MÀN HÌNH
                                    onBook(room);
                                  }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey[300],
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Chọn phòng',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // --------------------------
  // ICON CHO TIỆN NGHI
  // --------------------------
  IconData _getAmenityIcon(String amenity) {
    final amenityLower = amenity.toLowerCase();

    if (amenityLower.contains('wifi') || amenityLower.contains('internet')) {
      return Icons.wifi;
    } else if (amenityLower.contains('giường') ||
        amenityLower.contains('bed')) {
      return Icons.king_bed_rounded;
    } else if (amenityLower.contains('view') ||
        amenityLower.contains('cửa sổ')) {
      return Icons.window_rounded;
    } else if (amenityLower.contains('tắm') || amenityLower.contains('vòi')) {
      return Icons.bathroom_rounded;
    } else if (amenityLower.contains('ăn')) {
      return Icons.restaurant_rounded;
    }
    return Icons.check_circle;
  }

  // --------------------------
  // FORMAT GIÁ
  // --------------------------
  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    );
  }
}