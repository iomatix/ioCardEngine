class ImageLoadingException implements Exception {
  final String message;
  ImageLoadingException(this.message);

  @override
  String toString() => 'ImageLoadingException: $message';
}