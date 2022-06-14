class AuthorizationException implements Exception {
  final String message;
  AuthorizationException(this.message);

  @override
  String toString() => message;
}

class RemoteDataSourceException implements Exception {
  final String message;
  RemoteDataSourceException(this.message);

  @override
  String toString() => message;

}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => message;

}
