import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelMapSection extends StatelessWidget {
  final Hotel hotel;

  const HotelMapSection({super.key, required this.hotel});

  // --- KHAI BÁO MÀU SẮC (CẤU HÌNH UI) ---
  static const Color primaryColor = Color(0xFF2DBBAA);
  static const Color secondaryPastel = Color(0xFFE6FAF7);
  static const Color textDark = Color(0xFF1F2937);

  @override
  Widget build(BuildContext context) {
    if (hotel.latitude == null || hotel.longitude == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vị trí khách sạn',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),

          // ===== Address + Button =====
          Row(
            children: [
              const Icon(Icons.location_on, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hotel.address ?? 'Không có địa chỉ',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _openGoogleMap(context),
                icon: const Icon(Icons.directions, size: 18 , color: Colors.white,),
                label: const Text('Chỉ đường', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ===== Map Section =====
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(hotel.latitude!, hotel.longitude!),
                  zoom: 15.5,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("hotel_location"),
                    position: LatLng(hotel.latitude!, hotel.longitude!),
                    infoWindow: InfoWindow(
                      title: hotel.name,
                      snippet: "Nhấn để xem trên Google Maps",
                    ),
                  ),
                },
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                onTap: (_) => _openGoogleMap(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // mở google map
  void _openGoogleMap(BuildContext context) async {
    final lat = hotel.latitude!;
    final lng = hotel.longitude!;

    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể mở bản đồ')));
    }
  }
}
