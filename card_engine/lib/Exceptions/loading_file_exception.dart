class LoadingFileException implements Exception {
  final String message;
  LoadingFileException(this.message);

  @override
  String toString() => 'LoadingFileException: $message';
}