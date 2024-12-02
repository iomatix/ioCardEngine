class FileNotFoundException implements Exception {
  final String filePath;
  FileNotFoundException(this.filePath);

  @override
  String toString() => 'FileNotFoundException: File not found at $filePath';
}