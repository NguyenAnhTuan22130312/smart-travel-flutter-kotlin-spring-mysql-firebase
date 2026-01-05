class VoucherCreateRequest {
  final String code;
  final double discountAmount;
  final String expiryDate;
  final bool isActive;
  final int usageLimit;

  VoucherCreateRequest({
    required this.code,
    required this.discountAmount,
    required this.expiryDate,
    required this.isActive,
    required this.usageLimit,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'discountAmount': discountAmount,
      'expiryDate': expiryDate,
      'isActive': isActive,
      'usageLimit': usageLimit,
    };
  }
}