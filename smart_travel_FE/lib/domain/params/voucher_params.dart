class VoucherCreateParams {
  final String code;
  final double discountAmount;
  final DateTime expiryDate;
  final bool isActive;
  final int usageLimit;

  VoucherCreateParams({
    required this.code,
    required this.discountAmount,
    required this.expiryDate,
    required this.isActive,
    required this.usageLimit,
  });

  Map<String, dynamic> toJson() => {
    "code": code,
    "discountAmount": discountAmount,
    "expiryDate": expiryDate.toIso8601String(),
    "isActive": isActive,
    "usageLimit": usageLimit,
  };
}

class VoucherUpdateParams {
  final int id;
  final String code;
  final double discountAmount;
  final DateTime expiryDate;
  final bool isActive;
  final int usageLimit;

  VoucherUpdateParams({
    required this.id,
    required this.code,
    required this.discountAmount,
    required this.expiryDate,
    required this.isActive,
    required this.usageLimit,
  });

  Map<String, dynamic> toJson() => {
    "code": code,
    "discountAmount": discountAmount,
    "expiryDate": expiryDate.toIso8601String(),
    "isActive": isActive,
    "usageLimit": usageLimit,
  };
}