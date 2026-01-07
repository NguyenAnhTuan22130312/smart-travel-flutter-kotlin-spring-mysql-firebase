import 'dart:convert';

import 'package:smart_travel/data/models/destination/destination_image_response_modal.dart';
import 'package:smart_travel/data/models/province/province_response_modal.dart';
import 'package:smart_travel/domain/entities/destinations.dart';

class DestinationResponseModal {
  final int id;
  final String name;
  final String? description;
  final ProvinceModal? province;
  final String category;
  final double? latitude;
  final double? longitude;
  final String address;
  final double averageRating;
  final int reviewCount;
  final int viewCount;
  final String? openingHours;
  final bool isActive;
  final bool isFeatured;
  final double entryFee;
  final String imageUrl;
  final String? audioScript;
  final int? experienceReward;
  final List<DestinationImageResponse>? destinationImage;

  const DestinationResponseModal({
    required this.id,
    required this.name,
    this.description,
    this.province,
    required this.category,
    required this.address,
    this.latitude,
    this.longitude,
    required this.averageRating,
    required this.reviewCount,
    required this.viewCount,
    required this.openingHours,
    required this.isActive,
    required this.isFeatured,
    required this.entryFee,
    required this.imageUrl,
    required this.destinationImage ,
    required this.audioScript,
    required this.experienceReward
  });

  /// Hàm chuyển từ JSON sang model
  factory DestinationResponseModal.fromJson(Map<String, dynamic> json) {
    return DestinationResponseModal(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      province: json['province'] != null
          ? ProvinceModal.formJson(json['province'])
          : null,
      category: json['category'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      address: json['address'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      openingHours: json['openingHours'],
      isActive: json['isActive'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      entryFee: (json['entryFee'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      destinationImage: json['images'] != null
          ? (json['images'] as List)
          .map((e) => DestinationImageResponse.fromJson(e))
          .toList()
          : [],
      audioScript: json['audio_script'] ?? json['audioScript'],
      experienceReward: json['experience_reward'] ?? json['experienceReward'],
    );
  }
  DestinationEntity toEntity() {
    return DestinationEntity(
      id: id,
      name: name,
      province: province?.toEntity(),
      category: category,
      latitude: latitude,
      longitude: longitude,
      address: address,
      description: description,
      averageRating: averageRating,
      reviewCount: reviewCount,
      viewCount: viewCount,
      openingHours: openingHours != null
          ? _parseOpeningHours(openingHours!)
          : null,
      isActive: isActive,
      isFeatured: isFeatured,
      entryFee: entryFee,
      imageUrl: imageUrl,
      destinationImage : destinationImage?.map((d) => d.toEntity()).toList(),
      audioScript: audioScript,
      experienceReward: experienceReward,
    );
  }
  // Helper: Parse chuỗi openingHours → Map
  Map<String, dynamic> _parseOpeningHours(String hours) {
    try {
      // BE trả về JSON string: '{"Mon": "08:00-17:00", "Tue": "08:00-17:00"}'
      final decoded = json.decode(hours);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return {};
  }

}