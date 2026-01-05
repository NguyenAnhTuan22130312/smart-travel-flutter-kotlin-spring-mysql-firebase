class Voucher {
  final int id;
  final String code;
  final double discountAmount;
  final DateTime expiryDate;
  final bool isActive;
  final int usageLimit;

  const Voucher({
    required this.id,
    required this.code,
    required this.discountAmount,
    required this.expiryDate,
    required this.isActive,
    required this.usageLimit,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'],
      code: json['code'],
      discountAmount: (json['discountAmount'] as num).toDouble(),
      expiryDate: DateTime.parse(json['expiryDate']),
      isActive: json['isActive'] ?? true,
      usageLimit: json['usageLimit'] ?? 0,
    );
  }
}