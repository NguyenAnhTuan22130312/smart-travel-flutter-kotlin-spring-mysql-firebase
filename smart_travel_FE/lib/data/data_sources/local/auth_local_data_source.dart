import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_travel/data/models/auth/login_response_modal.dart';
abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<void> saveRole(String role);
  Future<void> saveRefreshToken(String refreshToken);
  Future<void> saveFullName(String role);
  Future<String?> getToken();
  Future<String?> getRefreshToken();
  Future<String?> getRole();
  Future<String?> getFullName();
  Future<void> clear();

}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl({required this.storage});

  static const _keyToken = 'token';
  static const _keyRole = 'role';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyFullName = 'fullName';


  @override
  Future<void> saveToken(String token) async =>
      await storage.write(key: _keyToken, value: token);

  @override
  Future<void> saveRefreshToken(String refreshToken) async =>
      await storage.write(key: _keyRefreshToken, value: refreshToken);

  @override
  Future<void> saveRole(String role) async =>
      await storage.write(key: _keyRole, value: role);

  @override
  Future<String?> getToken() async =>
      await storage.read(key: _keyToken);
  @override
  Future<String?> getRefreshToken() async =>
      await storage.read(key: _keyRefreshToken);

  @override
  Future<String?> getRole() async =>
      await storage.read(key: _keyRole);

  @override
  Future<void> saveFullName(String fullName) async {
    await storage.write(key: _keyFullName, value: fullName);
  }
  @override
  Future<String?> getFullName() async =>
      await storage.read(key: _keyFullName);

  @override
  Future<void> clear() async => await storage.deleteAll();


}