import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:mutex/mutex.dart';

import '../tools/file_tool.dart';

/// Manages user data directories by ensuring the existence of mandatory subdirectories,
/// handling the creation and removal of dynamic directories, and maintaining directory integrity.
///
/// **Contains interface to manage the app-user related data.**
class UserDataManager {
  /// Lockable memory access
  final Mutex _lock;

  /// Interval for run-time monitoring
  @Deprecated("This interval is not used anymore")
  static const _monitorInterval = Duration(milliseconds: 370);

  /// List of mandatory subdirectories to create under `user_data`.
  final Set<String> _mandatorySubDirectories = {
    'cards',
    'cards\\.placeholder',
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

  /// Initializes the user data by performing necessary local setup operations.
  Future<void> setupUserData() async {
    await _localSetup();
  }

  /// Initializes the user data directory by creating mandatory subdirectories
  /// and saving essential asset files.
  Future<void> _localSetup() async {
    final userDataPath = await getUserDataPath();
    // Create the user_data directory and mandatory subdirectories
    await FileTool().createDirectory(userDataPath);
    for (final subDir in List.from(_allSubDirectories)) {
      final path = await FileTool().normalizePath('$userDataPath/$subDir');
      await FileTool().createDirectory(path);
    }

    // Save placeholder.png to user_data/cards/.placeholder
    await FileTool().saveAssetToFile(
      assetPath:
          '${await FileTool().getCardEngineBundlerPath()}/assets/images/placeholder.png',
      filePath: await FileTool()
          .normalizePath('$userDataPath/cards/.placeholder/placeholder.png'),
    );

    // Copy placeholder-reverse.png to user_data
    await FileTool().saveAssetToFile(
      assetPath:
          '${await FileTool().getCardEngineBundlerPath()}/assets/images/placeholder-reverse.png',
      filePath: await FileTool().normalizePath(
          '$userDataPath/cards/.placeholder/placeholder-reverse.png'),
    );

    synchronizeUserData();
  }

  /// Gets the absolute path of the `user_data` directory
  Future<String> getUserDataPath({userName = "default"}) async {
    final directory = await getApplicationDocumentsDirectory();
    return await FileTool()
        .normalizePath('${directory.path}/Card Engine/$userName');
  }

  /// Monitor and handle changes to subdirectories periodically.
  ///
  /// This function initializes mandatory subdirectories if they don't exist and updates the list of all subdirectories within the user's data path every `interval` milliseconds. It also enforces mandatory directories by recreating them if they are missing.
  @Deprecated(
      "This function is not run periodically anymore, call checkAndUpdateSubDirectories on demand.")
  Future<void> monitorSubDirectoriesPeriodically(
      {Duration interval = _monitorInterval}) async {
    Timer.periodic(interval, (_) => synchronizeUserData());
  }

  /// Checks for changes in subdirectories and updates them accordingly.
  /// Ensures all mandatory directories are present and synchronizes the internal directory list.
  ///
  /// **Run this function to synchronize `user_data` with the application on demand**
  Future<void> synchronizeUserData() async {
    await _lock.protect(() async {
      try {
        final userDataPath = await getUserDataPath();
        final currentSubDirs = Directory(userDataPath)
            .listSync(recursive: true)
            .whereType<Directory>()
            .map((dir) => FileTool().normalizePathSync(dir.path.replaceFirst(
                RegExp('^${RegExp.escape(userDataPath)}[\\\\/]*'), '')))
            .toSet();
        if (currentSubDirs != _allSubDirectories) {
          await _updateAndEnforceMandatoryDirectories(currentSubDirs);
        }
      } catch (e) {
        if (e is PathNotFoundException) {
          _localSetup();
          print('Handling error $e - recreating user folder.');
        } else {
          rethrow;
        }
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
  Future<void> _addDynamicDirectory(String dirDynamicPath) async {
    _allSubDirectories.add(dirDynamicPath);
    final userDataPath = await getUserDataPath();
    final path =
        await FileTool().normalizePath('$userDataPath/$dirDynamicPath');
    try {
      await FileTool().createDirectory(path);
    } catch (e) {
      if (e is PathExistsException) {
        print('Directory already exists, skipping creation: $path');
      } else {
        rethrow; // Rethrow any exceptions to keep the error handling chain intact.
      }
    }
  }

  /// Remove a dynamic directory.
  ///
  /// This method removes the directory from `_allSubDirectories` and deletes it if possible.
  Future<void> _removeDynamicDirectory(String dirDynamicPath) async {
    _allSubDirectories.remove(dirDynamicPath);
    final userDataPath = await getUserDataPath();
    final path =
        await FileTool().normalizePath('$userDataPath/$dirDynamicPath');
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
  /// - Parameters:
  ///   - `category`: The name of the category (e.g., 'card', 'deck').
  ///   - `relativePath`: The relative path within the category.
  ///                   For example, use 'new_shiny_card/variant_1' to create a card with a variant directory.
  /// - Returns: A [Future] that completes when the category and its subdirectories have been created successfully.
  Future<void> createDynamicDirectory({
    required String category,
    required String relativePath,
  }) async {
    final path = await getDynamicDirectoryPath(
        category: category, relativePath: relativePath);

    // Add the new directory
    await _addDynamicDirectory(path);
  }

  /// Remove from a dynamic directory with its subdirectories.
  ///
  /// This method removes the specified category from `_allSubDirectories` and deletes it along with any of its subdirectories if possible,
  /// returning a future that completes when the deletion process is finished.
  ///
  /// - Parameters:
  ///   - `category`: The name of the category (e.g., 'card', 'deck').
  ///   - `relativePath`: The relative path within the category.
  ///
  /// - Returns: A [Future] that completes when the deletion process has finished. If an error occurs during deletion,
  ///         it will be printed and ignored, allowing the method to complete successfully regardless of whether the deletion was successful or not.
  Future<void> deleteDynamicDirectory({
    required String category,
    required String relativePath,
  }) async {
    final path = await getDynamicDirectoryPath(
        category: category, relativePath: relativePath);
    // Remove the new directory from _allSubDirectories using the private method
    await _removeDynamicDirectory(path);
  }

  /// Determines whether a dynamic directory exists for the specified category and relative path.
  ///
  /// - Parameters:
  ///   - `category`: The name of the category (e.g., 'card', 'deck').
  ///   - `relativePath`: The relative path within the category.
  /// - Returns: A [Future] that completes with true if the directory exists, false otherwise.
  Future<bool> doesDynamicDirectoryExist({
    required String category,
    required String relativePath,
  }) async {
    final path = await getDynamicDirectoryAbsolutePath(
        category: category, relativePath: relativePath);
    return (await FileTool().doesDirectoryExist(path) &&
        _allSubDirectories.contains(await getDynamicDirectoryPath(
            category: category, relativePath: relativePath)));
  }

  /// Gets the normalized path for a dynamic directory based on the specified category and relative path.
  ///
  /// - Parameters:
  ///   - `category`: The category of the directory.
  ///   - `relativePath`: The relative path within the category.
  /// - Returns: A [Future] that completes with the normalized directory path.
  Future<String> getDynamicDirectoryPath({
    required String category,
    required String relativePath,
  }) async {
    return await FileTool().normalizePath('$category/$relativePath');
  }

  /// Retrieves the absolute normalized path for a dynamic directory based on the specified category and relative path.
  ///
  /// - Parameters:
  ///   - `category`: The category of the directory.
  ///   - `relativePath`: The relative path within the category.
  /// - Returns: A [Future] that completes with the absolute normalized directory path.
  Future<String> getDynamicDirectoryAbsolutePath({
    required String category,
    required String relativePath,
  }) async {
    String userDataPath = await getUserDataPath();
    String dynamicPath = await getDynamicDirectoryPath(
        category: category, relativePath: relativePath);
    return await FileTool().normalizePath('$userDataPath/$dynamicPath');
  }
}
