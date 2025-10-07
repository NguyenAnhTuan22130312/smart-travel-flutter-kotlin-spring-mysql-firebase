import 'package:flutter_secure_storage/flutter_secure_storage.dart';
abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<void> saveRefreshToken(String refreshToken);
  Future<void> saveRole(String role);
  Future<String?> getToken();
  Future<String?> getRole();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl({required this.storage});

  static const _keyToken = 'token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyRole = 'role';

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
  Future<String?> getRole() async =>
      await storage.read(key: _keyRole);

  @override
  Future<void> clear() async => await storage.deleteAll();
}