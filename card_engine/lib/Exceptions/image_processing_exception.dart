class ImageProcessingException implements Exception {
  final String message;
  ImageProcessingException(this.message);

  @override
  String toString() => 'ImageProcessingException: $message';
}