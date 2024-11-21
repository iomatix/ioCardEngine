import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

///
/// Set of methods to handle binary files.
///
class FileTool {
  FileTool();

  /// Asynchronously reads a file from the application's bundle and returns its contents as a `Uint8List`.
  ///
  /// If the file does not exist or is corrupted, an empty `Uint8List` will be returned.
  ///
  /// @param path The path to the file within the application's bundle.
  /// return A future that completes with the file contents as a `Uint8List`, or an empty `Uint8List` if there was an error.
  static Future<Uint8List> openFileAsUint8List(String path) async {
    var logger = Logger();

    try {
      // Load the binary data from the specified file path within the application's bundle
      final ByteData data = await rootBundle.load(path);
      // Convert the loaded byte data to a Uint8List and return it
      final Uint8List bytes = data.buffer.asUint8List();
      return bytes;
    } catch (err) {
      // Log any errors that occurred during file loading with the Logger package
      logger.f("The file doesn't exist or is corrupted.", error: err);
      // Return an empty Uint8List if there was an error
      return Uint8List(0);
    }
  }
}
