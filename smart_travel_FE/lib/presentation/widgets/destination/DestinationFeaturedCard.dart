// Destination Card Widget
import 'package:flutter/material.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

import '../../../domain/entities/destinations.dart';
class DestinationFeatured  extends StatefulWidget {
    final DestinationEntity destinationEntity;

   const DestinationFeatured(this.destinationEntity, {super.key});


  @override
  State<DestinationFeatured> createState()=> _DestinationFeaturedState();

}

class _DestinationFeaturedState extends State<DestinationFeatured> {
  @override
  Widget build(BuildContext context) {
    return _buildDestinationCard(widget.destinationEntity);
  }

  Widget _buildDestinationCard(DestinationEntity destination) {
    final entryFee = destination.entryFee;
    final priceText =
    entryFee == 0
        ? 'Miễn phí'
        : '${entryFee?.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to destination detail
        // Navigator.pushNamed(context, '/destination/detail', arguments: destination['id']);
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Image placeholder
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child:
                    destination.imageUrl != null &&
                        destination.imageUrl!.isNotEmpty
                        ? Image.network(
                      destination.imageUrl!,
                      fit: BoxFit.cover,
                    )
                        : Image.asset("assets/images/img.png",
                    fit: BoxFit.cover,
                    )
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          destination.averageRating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${destination.reviewCount})',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.textGray,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.province,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        priceText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}