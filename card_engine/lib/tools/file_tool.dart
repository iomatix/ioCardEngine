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

  Future<bool> doesDirectoryExist(String path) async {
    final dir = Directory(path);
    return await dir.exists();
  }

  Future<void> createDirectory(String path) async {
    if (!(await doesDirectoryExist(path))) {
      await Directory(path).create(recursive: true);
    }
  }

  Future<void> deleteDirectory(String path) async {
    if (await doesDirectoryExist(path)) {
      await Directory(path).delete(recursive: true);
    }
  }

  Future<void> saveAssetToFile({
    required String assetPath,
    required String filePath,
  }) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final file = File(filePath);

      // Check if the file already exists and is not empty
      if (!(await file.exists() && await file.length() > 0)) {
        await file.writeAsBytes(
          byteData.buffer
              .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
      } else {
        print('File already exists and is not empty. Not overwriting.');
      }
    } catch (e) {
      print('Error occurred while saving asset to file: $e');
    }
  }

  Future<void> saveAssetToFileAndOverwrite({
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
