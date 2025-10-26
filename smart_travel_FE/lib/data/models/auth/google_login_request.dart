class GoogleLoginRequest {
  final String idToken;
  final String email;
  final String displayName;

  GoogleLoginRequest({
    required this.idToken,
    required this.email,
    required this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
      'email': email,
      'displayName': displayName,
    };
  }
}