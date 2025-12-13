class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  // Chuyển từ Json → Modal (data)
  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json){
    return RefreshTokenRequest(
      refreshToken: json['refreshToken'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}
