import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/favorite/favorite_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_bloc.dart';
import 'package:smart_travel/presentation/blocs/profile/profile_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/presentation/widgets/destination/share_to_group_bottom_sheet.dart';
import 'package:smart_travel/router/route_names.dart';

class DestinationCart extends StatefulWidget {
  final DestinationEntity destinationEntity;

  const DestinationCart(this.destinationEntity, {super.key});

  @override
  State<DestinationCart> createState() => _DestinationFeaturedState();
}

class _DestinationFeaturedState extends State<DestinationCart> {
  @override
  Widget build(BuildContext context) {
    return _buildDestinationCard(widget.destinationEntity);
  }

  Widget _buildDestinationCard(DestinationEntity destination) {
    final entryFee = destination.entryFee;
    final priceText = entryFee == 0
        ? 'Miễn phí'
        : '${entryFee?.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    )}đ';

    String imageUrl = (destination.destinationImage != null &&
        destination.destinationImage!.isNotEmpty)
        ? destination.destinationImage![0].imageUrl ?? ""
        : (destination.imageUrl ?? "");

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/destination-detail',
          arguments: (
          id: destination.id,
          lat: destination.latitude,
          lng: destination.longitude,
          ),
        );
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.all(0),
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
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: destination.destinationImage != null &&
                        destination.destinationImage!.isNotEmpty
                        ? Image.network(
                      destination.destinationImage![0].imageUrl ?? "",
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      "assets/images/img.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Action Buttons Row (Favorite + Share)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      // Share Button
                      GestureDetector(
                        onTap: () =>

                            _showShareToGroupDialog(context, destination, imageUrl, priceText),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.share,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Favorite Button
                      BlocBuilder<FavoriteBloc, FavoriteState>(
                        builder: (context, state) {
                          final isFavorite = state.favoriteItems
                              .any((x) => x['id'] == destination.id.toString());

                          return GestureDetector(
                            onTap: () {
                              if (isFavorite) {
                                context.read<FavoriteBloc>().add(
                                  RemoveFromFavorite(destination.id.toString()),
                                );
                              } else {
                                context.read<FavoriteBloc>().add(
                                  AddToFavorite({
                                    'id': destination.id.toString(),
                                    'name': destination.name,
                                    'category': destination.category ?? 'Địa điểm',
                                    'location': destination.province?.name ?? 'Việt Nam',
                                    'image': imageUrl,
                                    'rating': destination.averageRating,
                                    'price': priceText,
                                  }),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: isFavorite ? Colors.red : AppColors.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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
                          destination.province!.name,
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

  /// Dialog chọn nhóm để chia sẻ
  void _showShareToGroupDialog(
      BuildContext context,
      DestinationEntity destination,
      String imageUrl,
      String priceText,
      ) {
    final profileState = context.read<ProfileBloc>().state;

    // 1. Kiểm tra đăng nhập
    if (profileState is! ProfileLoaded) {
      _showLoginRequiredDialog(context);
      return;
    }

    final user = profileState.user;

    // 2. Mở Bottom Sheet và truyền dữ liệu địa điểm
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShareToGroupScreen(
          destination: destination,
          imageUrl: imageUrl,
          priceText: priceText,
          currentUserId: user.id.toString(),
          currentUserName: user.fullName,
          currentUserAvatar: user.avatarUrl,
        ),
      ),
    );
  }
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yêu cầu đăng nhập'),
        content: const Text(
          'Bạn cần đăng nhập để chia sẻ địa điểm vào nhóm du lịch.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.login);
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }
}