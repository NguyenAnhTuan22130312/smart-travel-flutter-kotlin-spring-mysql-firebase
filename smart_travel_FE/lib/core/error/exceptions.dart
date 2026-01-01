class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class TokenExpiredException implements Exception {
  final String message;
  const TokenExpiredException([
    this.message = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
  ]);
}
