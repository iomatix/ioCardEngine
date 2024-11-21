import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class UserDataManager {

  
  /// List of subdirectories to create under `user_data`.
  final List<String> subDirectories = [
    'cards',
    'decks',
    // ...
    '.temp'
  ];

  UserDataManager();
  Future<void> setupUserData() async {

    final userDataPath = await _getUserDataPath();
    // Create the user_data directory and subdirectories
    final userDataDir = Directory(userDataPath);
    if (!await userDataDir.exists()) {
      await userDataDir.create(recursive: true);
    }

    for (var subDir in subDirectories) {
      final path = '$userDataPath/$subDir';
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }

    // Save placeholder.png to user_data/cards/.placeholder
    await _saveAssetToFile(
      assetPath: 'assets/images/placeholder.png',
      filePath: '$userDataPath/cards/placeholder.png',
    );

    // Copy placeholder-reverse.png to user_data
    await _saveAssetToFile(
      assetPath: 'assets/images/placeholder-reverse.png',
      filePath: '$userDataPath/cards/placeholder-reverse.png',
    );
  }

  /// Get the application documents directory
  Future<String> _getUserDataPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/Card Engine/user_data';
  }

  /// Utility function to save an asset to a specific file path.
  Future<void> _saveAssetToFile({
    required String assetPath,
    required String filePath,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      final byteData = await rootBundle.load('card_engine/$assetPath');
      final buffer = byteData.buffer;
      await file.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    }
  }
}
