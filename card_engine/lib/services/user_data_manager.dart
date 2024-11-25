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
    'cards/.placeholder',
    'decks',
    '.temp'
  };

  /// Set of all mandatory and dynamic subdirectories.
  ///
  /// Dynamic directories are added via `_addDynamicDirectory` method.
  Set<String> _allSubDirectories = {};

  UserDataManager() : _lock = Mutex() {
    _allSubDirectories = {..._mandatorySubDirectories};
  }

  /// Get the package directory for bundler
  Future<String> getCardEngineBundlerPath() async => 'packages/card_engine';

  Future<void> setupUserData() async {
    final userDataPath = await getUserDataPath();
    // Create the user_data directory and mandatory subdirectories
    await FileTool().createDirectory(userDataPath);
    for (final subDir in _allSubDirectories) {
      final path = '$userDataPath/$subDir';
      await FileTool().createDirectory(path);
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
  /// This function initializes mandatory subdirectories if they don't exist and updates the list of all subdirectories within the user's data path every `interval` milliseconds. It also enforces mandatory directories by recreating them if they are missing.
  Future<void> monitorSubDirectoriesPeriodically(
      {Duration interval = _monitorInterval}) async {
    Timer.periodic(interval, (_) => _checkAndUpdateSubDirectories());
  }

  /// Check and update subdirectories if there are changes. If a mandatory directory is missing, it will be recreated.
  Future<void> _checkAndUpdateSubDirectories() async {
    await _lock.protect(() async {
      try {
        final userDataPath = await getUserDataPath();
        final currentSubDirs = Directory(userDataPath)
            .listSync(recursive: true)
            .whereType<Directory>()
            .map((dir) => dir.path.replaceFirst(userDataPath, ''))
            .toSet();
        if (currentSubDirs != _allSubDirectories) {
          await _updateAndEnforceMandatoryDirectories(currentSubDirs);
        }
      } catch (e) {
        print('Error checking subdirectories: $e');
      }
    });
  }

  /// Update and enforce mandatory directories.
  ///
  /// This method adds new dynamic directories, recreates missing mandatory directories, and removes unused dynamic directories.
  Future<void> _updateAndEnforceMandatoryDirectories(
      Set<String> currentSubDirs) async {
    // Add new dynamic directories
    final newDynamicDirs = currentSubDirs.difference(_allSubDirectories);
    for (final dir in newDynamicDirs) {
      if (!_mandatorySubDirectories
          .any((mandatoryDir) => dir.startsWith(mandatoryDir))) {
        await _addDynamicDirectory(dir);
      }
    }

    // Recreate missing mandatory directories
    final missingMandatoryDirs = _mandatorySubDirectories.where(
      (dir) => !currentSubDirs.contains(dir),
    );
    for (final dir in missingMandatoryDirs) {
      await _addDynamicDirectory(dir);
    }

    // Remove unused dynamic directories
    final unusedDynamicDirs = _allSubDirectories
        .difference(currentSubDirs)
        .difference(_mandatorySubDirectories);
    for (final dir in unusedDynamicDirs) {
      await _removeDynamicDirectory(dir);
    }
  }

  /// Add a new dynamic directory.
  ///
  /// This method creates the directory and adds it to `_allSubDirectories`.
  Future<void> _addDynamicDirectory(String dirName) async {
    final userDataPath = await getUserDataPath();
    final path = '$userDataPath/$dirName';
    await FileTool().createDirectory(path);
    _allSubDirectories.add(dirName);
  }

  /// Remove a dynamic directory.
  ///
  /// This method removes the directory from `_allSubDirectories` and deletes it if possible.
  Future<void> _removeDynamicDirectory(String dirName) async {
    final userDataPath = await getUserDataPath();
    final path = '$userDataPath/$dirName';
    _allSubDirectories.remove(dirName);

    try {
      await FileTool().deleteDirectory(path);
    } catch (e) {
      if (e is PathNotFoundException) {
        print('Directory not found, skipping deletion: $path');
      } else {
        rethrow; // Rethrow other exceptions to keep the error handling chain intact.
      }
    }
  }

  /// Add new subdirectories to dynamic directory or create new one.
  ///
  /// This method creates the specified category directory along with any required subdirectories,
  /// adds it to `_allSubDirectories`, and returns the created path.
  ///
  /// @param category The name of the category (e.g., 'card', 'deck').
  /// @param relativePath The relative path for the new category, including any desired subdirectories.
  ///                     For example, use 'new_shiny_card/variant_1' to create a card with a variant directory.
  ///
  /// @return A future that completes when the category and its subdirectories have been created successfully.
  Future<void> createDirectory({
    required String category,
    required String relativePath,
  }) async {
    final userDataPath = await getUserDataPath();
    final path = '$userDataPath/$category/$relativePath';

    // Create the main category and its subdirectory
    await FileTool().createDirectory(path);

    // Add the new directory to _allSubDirectories using the private method
    _addDynamicDirectory('$category/$relativePath');
  }

  /// Remove from a dynamic directory with its subdirectories.
  ///
  /// This method removes the specified category from `_allSubDirectories` and deletes it along with any of its subdirectories if possible,
  /// returning a future that completes when the deletion process is finished.
  ///
  /// @param category The name of the category (e.g., 'card', 'deck').
  /// @param relativePath The relative path for the category to be deleted, including any desired subdirectories.
  ///
  /// @return A future that completes when the deletion process has finished. If an error occurs during deletion,
  ///         it will be printed and ignored, allowing the method to complete successfully regardless of whether the deletion was successful or not.
  Future<void> deleteDirectory({
    required String category,
    required String relativePath,
  }) async {
    final userDataPath = await getUserDataPath();
    final path = '$userDataPath/$category/$relativePath';

    // Remove the new directory from _allSubDirectories using the private method
    _removeDynamicDirectory('$category/$relativePath');

    // Delete the category and its subdirectory if possible
    try {
      await FileTool().deleteDirectory(path);
    } catch (e) {
      print('Error occurred while deleting category: $e');
    }
  }
}
