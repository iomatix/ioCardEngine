import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class UserDataManager {

  
  /// List of subdirectories to create under `user_data`.
  final List<String> subDirectories = [
    'cards',
    'decks',
    // ...
    '.temp',
    'cards/.placeholder'
  ];

  UserDataManager();
  Future<void> setupUserData() async {

    final userDataPath = await getUserDataPath();
    // Create the user_data directory and subdirectories
    _createDirectoryIfNotExists(userDataPath);
    for (var subDir in subDirectories) {
      final path = '$userDataPath/$subDir';
      _createDirectoryIfNotExists(path);
    }

    // Save placeholder.png to user_data/cards/.placeholder
    await _saveAssetToFile(
      assetPath: 'assets/images/placeholder.png',
      filePath: '$userDataPath/cards/.placeholder/placeholder.png',
    );

    // Copy placeholder-reverse.png to user_data
    await _saveAssetToFile(
      assetPath: 'assets/images/placeholder-reverse.png',
      filePath: '$userDataPath/cards/.placeholder/placeholder-reverse.png',
    );
  }

  /// Get the application documents directory
  Future<String> getUserDataPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/Card Engine/user_data';
  }

  /// Get the package directory for bundler
  Future<String> getCardEngineBundlerPath() async {
    return 'packages/card_engine';
  }

  // Utility function to create a directory if it does not exist.
  Future<void> _createDirectoryIfNotExists(String path) async { 
    final dir = Directory(path); 
    if (!await dir.exists()) { 
      await dir.create(recursive: true); 
      }
  }

  /// Utility function to save an asset to a specific file path.
  Future<void> _saveAssetToFile({
    required String assetPath,
    required String filePath,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      final byteData = await rootBundle.load('${await getCardEngineBundlerPath()}/$assetPath');
      final buffer = byteData.buffer;
      await file.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    }
    else {
      // TODO: File exists, overwrite? Throw an error to interface to let the user to handle it by pressing button.
    }
  }
}
