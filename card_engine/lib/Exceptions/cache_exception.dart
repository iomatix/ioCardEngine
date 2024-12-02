class CacheException implements Exception {
  final String message;
  final String cacheKeyName;
  CacheException(this.message, {required this.cacheKeyName});

  @override
  String toString() => 'CacheException: $message [Cache Key: $cacheKeyName]';
}