class FileFormatException implements Exception {
  final String message;
  FileFormatException(this.message);

  @override
  String toString() => 'FileFormatException: $message';
}