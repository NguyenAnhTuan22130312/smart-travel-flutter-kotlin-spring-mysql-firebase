import 'package:smart_travel/domain/entities/auth.dart';

class LoginResponseModal {
  final String token;
  final String? refreshToken;
  final String? role;
  final String? fullName;

  LoginResponseModal({required this.token,
    required this.refreshToken, required this.role, required this.fullName});


  // Chuyển từ Json → Modal (data)
  factory LoginResponseModal.fromJson(Map<String, dynamic> json){
      return LoginResponseModal(
          token: json['token'] as String,
          refreshToken: json['refreshToken'] as String?,
          role: json['role'] as String?,
          fullName: json['fullName'] as String?,
      );
  }

  // Chuyển từ Model → Entity (domain)
  AuthEntity toEntity() {
    return AuthEntity(
      fullName: fullName,
      token: token,
      refreshToken: refreshToken,
      role: role,
    );
  }
}