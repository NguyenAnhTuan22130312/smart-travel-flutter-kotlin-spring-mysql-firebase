import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/invoice/review_bloc.dart';
import '../../blocs/invoice/review_event.dart';
import '../../screens/review/review_submit_screen.dart';
import '../../theme/app_colors.dart';

class InvoiceReviewCard extends StatelessWidget {
  final int bookingId;
  final String invoiceNumber;
  final String itemName;
  final String startDate;
  final String endDate;
  final int nights;
  final String status;
  final bool reviewed;

  const InvoiceReviewCard({
    Key? key,
    required this.bookingId,
    required this.invoiceNumber,
    required this.itemName,
    required this.startDate,
    required this.endDate,
    required this.nights,
    required this.status,
    required this.reviewed,
  }) : super(key: key);

  String _formatDate(String date) {
    List<String> parts = date.split('-');
    return "${parts[2]}/${parts[1]}/${parts[0]}";
  }

  @override
  Widget build(BuildContext context) {
    bool isHotel = nights > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mã đặt chỗ (không có menu)
          Text(
            "Mã đặt chỗ: $invoiceNumber",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),

          // Tên tour/khách sạn
          Row(
            children: [
              Icon(
                isHotel ? Icons.hotel_outlined : Icons.tour_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  itemName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Ngày + số đêm
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
                    children: [
                      TextSpan(text: "${_formatDate(startDate)} - ${_formatDate(endDate)}"),
                      if (isHotel) ...[
                        const TextSpan(text: " · "),
                        TextSpan(
                          text: "$nights đêm",
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // NÚT ĐÁNH GIÁ LỚN
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: reviewed
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewSubmitScreen(
                      invoiceNumber: invoiceNumber,
                      serviceName: itemName,
                    ),
                  ),
                ).then((result) {
                  if (result == true) {

                    context.read<ReviewBloc>().add(LoadReviewableInvoices());
                  }
                });
              },
              icon: const Icon(Icons.star_border, size: 20),
              label: const Text(
                "Hãy đánh giá trải nghiệm của bạn",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}