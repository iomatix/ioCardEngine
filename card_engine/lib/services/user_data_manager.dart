import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:mutex/mutex.dart';

import '../tools/file_tool.dart';

class UserDataManager {
  // Lockable memory access
  final Mutex _lock;
  // Interval for run-time monitoring
  static const _monitorInterval = Duration(milliseconds: 170);

  /// List of mandatory subdirectories to create under `user_data`.
  final Set<String> _mandatorySubDirectories = {
    'cards',
    'decks',
    '.temp',
    'cards/.placeholder'
  };

  /// List of all subdirectories, including dynamically added ones.
  Set<String> subDirectories = {};

  UserDataManager() : _lock = Mutex() {
    subDirectories = {..._mandatorySubDirectories};
  }

  /// Get the package directory for bundler
  Future<String> getCardEngineBundlerPath() async => 'packages/card_engine';

  Future<void> setupUserData() async {
    final userDataPath = await getUserDataPath();
    // Create the user_data directory and subdirectories
    FileTool().createDirectoryIfNotExists(userDataPath);
    for (var subDir in subDirectories) {
      final path = '$userDataPath/$subDir';
      FileTool().createDirectoryIfNotExists(path);
    }

    // Save placeholder.png to user_data/cards/.placeholder
    await FileTool().saveAssetToFile(
      assetPath:
          '${await getCardEngineBundlerPath()}/assets/images/placeholder.png',
      filePath: '$userDataPath/cards/.placeholder/placeholder.png',
    );

    // Copy placeholder-reverse.png to user_data
    await FileTool().saveAssetToFile(
      assetPath:
          '${await getCardEngineBundlerPath()}/assets/images/placeholder-reverse.png',
      filePath: '$userDataPath/cards/.placeholder/placeholder-reverse.png',
    );

    // Run cat watch
    await monitorSubDirectoriesPeriodically();
  }

  /// Get the application documents directory
  Future<String> getUserDataPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/Card Engine/user_data';
  }

  /// Monitor and handle changes to subdirectories periodically.
  ///
  /// This function initializes mandatory subdirectories if they don't exist and updates the list of all subdirectories within the user's data path every `interval` milliseconds.
  Future<void> monitorSubDirectoriesPeriodically(
      {Duration interval = _monitorInterval}) async {
    // Run timer to check for changes periodically
    Timer.periodic(interval, (_) => _checkAndUpdateSubDirectories());
  }

  /// Check and update subdirectories if there are changes.
  Future<void> _checkAndUpdateSubDirectories() async {
    await _lock.protect(() async {
      try {
        final userDataPath = await getUserDataPath();
        final currentSubDirs = Directory(userDataPath)
            .listSync()
            .whereType<Directory>()
            .map((dir) => dir.path.replaceFirst(userDataPath, ''))
            .toSet();
        if (currentSubDirs != subDirectories) {
          await _updateSubDirectories(currentSubDirs);
        }
      } catch (e) {
        print('Error checking subdirectories: $e');
      }
    });
  }

  Future<void> _updateSubDirectories(Set<String> newSubDirs) async {
    try {
      subDirectories.addAll(newSubDirs.difference(subDirectories));
    } catch (e) {
      print('Error occurred while updating subdirectories: $e');
    }
  }
}
