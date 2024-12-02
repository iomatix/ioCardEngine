class ImageDecodingException implements Exception {
  final String message;
  ImageDecodingException(this.message);

  @override
  String toString() => 'ImageDecodingException: $message';
}