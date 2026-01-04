import 'package:smart_travel/domain/entities/voucher.dart';

class VoucherResponseModel {
  final int? id;
  final String? code;
  final double? discountAmount;
  final String? expiryDate; // API trả về String ISO-8601
  final bool? isActive;
  final int? usageLimit;

  VoucherResponseModel({
    this.id,
    this.code,
    this.discountAmount,
    this.expiryDate,
    this.isActive,
    this.usageLimit,
  });

  factory VoucherResponseModel.fromJson(Map<String, dynamic> json) {
    return VoucherResponseModel(
      id: json['id'],
      code: json['code'],
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      expiryDate: json['expiryDate'],
      isActive: json['isActive'],
      usageLimit: json['usageLimit'],
    );
  }

  Voucher toEntity() {
    return Voucher(
      id: id ?? 0,
      code: code ?? 'UNKNOWN',
      discountAmount: discountAmount ?? 0.0,
      expiryDate: expiryDate != null ? DateTime.parse(expiryDate!) : DateTime.now(),
      isActive: isActive ?? false,
      usageLimit: usageLimit ?? 0,
    );
  }
}