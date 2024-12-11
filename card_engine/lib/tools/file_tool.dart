import 'dart:io';
import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

import 'package:flutter/services.dart' show ByteData, rootBundle;

import '../Exceptions/loading_file_exception.dart';

///
/// Set of methods to handle binary files and directories.
///
class FileTool {
  static final FileTool _instance = FileTool._internal();
  
  static final Logger _logger = Logger();

  FileTool._internal();

  factory FileTool() {
    return _instance;
  }

  /// Get the package directory for bundler
  Future<String> getCardEngineBundlerPath() async => 'packages/card_engine';

  /// Asynchronously opens a file at [filePath], reads its binary data, and returns it as a list of integers.
  ///
  /// Throws an exception if the file is empty or if an error occurs during reading.
  Future<Uint8List> openFileAsUint8List(String filePath) async {
    try {
      // Get the absolute path of the provided file.
      final absoluteFilePath = File(filePath).absolute.path;

      // Load the binary data from the specified file path on device storage.
      final bytes = File(absoluteFilePath).readAsBytesSync();

      if (bytes.isEmpty) {
        throw LoadingFileException("The file is empty or doesn't exist.");
      }

      return bytes;
    } catch (err) {
      // Rethrow the error with a custom message including the file path and original error.
      throw LoadingFileException(
          "Failed to load file  '$filePath'. Error: $err");
    }
  }

  Future<File> readFile(String filePath) async {
    try {
      // Get the absolute path of the provided file.
      final absoluteFilePath = File(filePath).absolute.path;

      // Load the file from absolute path.
      return File(absoluteFilePath);
    } catch (err) {
      // Rethrow the error with a custom message including the file path and original error.
      throw LoadingFileException(
          "Failed to load file '$filePath'. Error: $err");
    }
  }

  /// Reads the contents of a [File] as a [Uint8List].
  ///
  /// @param file The [File] to be read.
  ///
  /// @return A `Future<Uint8List>` containing the file's byte data.
  ///
  /// @throws [ImageProcessingException] if the file cannot be read.
  Future<Uint8List> readFileAsUint8List(File file) async {
    try {
      return await file.readAsBytes();
    } catch (e, stackTrace) {
      _logger.f(
        "Failed to read file: ${file.path}",
        error: e,
        stackTrace: stackTrace,
      );
      throw LoadingFileException('Failed to read file: ${file.path}');
    }
  }

  /// Converts ByteData to a List of uint8 integers.
  ///
  /// Extracts the bytes from the provided ByteData and returns them as a List<int>.
  Future<List<int>> byteDataToListInt(ByteData byteData) async {
    final buffer = byteData.buffer;
    return buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  }

  /// Checks if a directory exists at the specified absolute path.
  ///
  /// Returns `true` if the directory exists, otherwise `false`.
  Future<bool> doesDirectoryExist(String absolutePath) async {
    final dir = Directory(absolutePath);
    return await dir.exists();
  }

  /// Creates a directory at the specified absolute path if it does not already exist.
  ///
  /// If necessary, parent directories will also be created.
  ///
  /// [absolutePath] The absolute path where the directory should be created.
  ///
  /// Returns a [Future] that completes when the directory is created.
  Future<void> createDirectory(String absolutePath) async {
    if (!(await doesDirectoryExist(absolutePath))) {
      // Create the directory and its parent directories, if necessary.
      await Directory(absolutePath).create(recursive: true);
    }
  }

  /// Deletes the directory at the specified absolute path if it exists.
  ///
  /// This method checks for the existence of the directory at [absolutePath]. If the directory
  /// exists, it and all of its contents are removed recursively.
  ///
  /// [absolutePath] The absolute path of the directory to delete.
  ///
  /// Returns a [Future] that completes when the directory has been deleted.
  Future<void> deleteDirectory(String absolutePath) async {
    if (await doesDirectoryExist(absolutePath)) {
      // Delete the directory and all of its contents recursively.
      await Directory(absolutePath).delete(recursive: true);
    }
  }

  /// Saves an app-bundled asset from [assetPath] to a file at [filePath].
  ///
  /// **This method will not overwrite the file if it already exists, use [saveAssetToFileAndOverwrite] method instead to overwrite existing files.**
  ///
  /// If the file does not exist or is empty, writes the asset's binary data to the file.
  /// If the file already exists and is not empty, it does not overwrite the file.
  Future<void> saveAssetToFile({
    required String assetPath,
    required String filePath,
  }) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final file = File(filePath);

      // Check if the file already exists and is not empty.
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

  /// Saves an app-bundled asset from [assetPath] to [filePath], overwriting the file if it exists.
  ///
  /// Loads the asset's binary data and writes it to the specified file path, replacing any existing content.
  ///
  /// Throws an exception if an error occurs during the process.
  Future<void> saveAssetToFileAndOverwrite({
    required String assetPath,
    required String filePath,
  }) async {
    try {
      final byteData = await rootBundle.load(assetPath);

      // Overwrite the contents of the file with the data from the asset.
      await File(filePath).writeAsBytes(
        byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    } catch (e) {
      print('Error occurred while saving asset to file: $e');
    }
  }

  /// Asynchronously normalizes the given [path] to a standard format.
  ///
  /// Returns [Future]<[String]> of the normalized path.
  Future<String> normalizePath(String path) async {
    return p.normalize(path);
  }

  /// Synchronously normalizes the given [path] to a standard format.
  ///
  /// Returns the normalized path as a [String].
  String normalizePathSync(String path) {
    return p.normalize(path);
  }

  Future<bool> checkFilesExtensions(
      List<File> files, List<String> extensions) async {
    return files.every((file) {
      String extension = getFileExtension(file);

      // Check if the file has an extension and if it's valid
      if (extension.isEmpty) {
        return false; // File doesn't have an extension
      }
      return extensions.contains(extension);
    });
  }

  /// Extracts the file extension from a [File].
  ///
  /// @param file The [File] from which to extract the extension.
  ///
  /// @return The file lower cased extension without the dot, or an empty string if none found.
  String getFileExtension(File file) {
    final filePath = file.path;
    final dotIndex = filePath.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < filePath.length - 1) {
      return filePath.substring(dotIndex + 1).toLowerCase();
    }
    return '';
  }
}
