class ImageSizeDoesNotMatchException implements Exception {
  final String message;
  ImageSizeDoesNotMatchException(this.message);

  @override
  String toString() => 'ImageSizeDoesNotMatchException: $message';
}