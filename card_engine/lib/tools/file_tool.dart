import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

///
/// Set of methods to handle binary files.
///
class FileTool {
  FileTool();

  Future<List<int>> openFileAsUint8List(String filePath) async {
    try {

      final filePath = File('filePath').absolute.path;

      // Load the binary data from the specified file path on device storage
      final bytes = File(filePath).readAsBytesSync();

      if (bytes.isEmpty) {
        throw Exception("The file is empty or doesn't exist.");
      }

      return bytes;
    } catch (err) {
      throw Exception("Failed to load file '$filePath'. Error: $err");
    }
  }

  Future<List<int>> byteDataToListInt(ByteData byteData) async {
    final buffer = byteData.buffer;
    return buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  }

  Future<void> createDirectoryIfNotExists(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  Future<void> saveAssetToFile({
    required String assetPath,
    required String filePath,
  }) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      await File(filePath).writeAsBytes(
        byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    } catch (e) {
      print('Error occurred while saving asset to file: $e');
    }
  }
}
