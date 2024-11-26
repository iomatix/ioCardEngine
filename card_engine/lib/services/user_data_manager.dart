import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:mutex/mutex.dart';

import '../tools/file_tool.dart';

class UserDataManager {
  // Lockable memory access
  final Mutex _lock;

  // Interval for run-time monitoring
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

  /// Get the package directory for bundler
  Future<String> getCardEngineBundlerPath() async => 'packages/card_engine';

  Future<void> setupUserData() async {
    await _localSetup();
  }

  Future<void> _localSetup() async {
    final userDataPath = await getUserDataPath();
    // Create the user_data directory and mandatory subdirectories
    await FileTool().createDirectory(userDataPath);
    for (final subDir in List.from(_allSubDirectories)) {
      final path = p.normalize('$userDataPath/$subDir');
      await FileTool().createDirectory(path);
    }

    // Save placeholder.png to user_data/cards/.placeholder
    await FileTool().saveAssetToFile(
      assetPath:
          '${await getCardEngineBundlerPath()}/assets/images/placeholder.png',
      filePath: p.normalize('$userDataPath/cards/.placeholder/placeholder.png'),
    );

    // Copy placeholder-reverse.png to user_data
    await FileTool().saveAssetToFile(
      assetPath:
          '${await getCardEngineBundlerPath()}/assets/images/placeholder-reverse.png',
      filePath: p.normalize(
          '$userDataPath/cards/.placeholder/placeholder-reverse.png'),
    );
  }

  /// Get the application documents directory
  Future<String> getUserDataPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return p.normalize('${directory.path}/Card Engine/user_data');
  }

  /// Monitor and handle changes to subdirectories periodically.
  ///
  /// This function initializes mandatory subdirectories if they don't exist and updates the list of all subdirectories within the user's data path every `interval` milliseconds. It also enforces mandatory directories by recreating them if they are missing.
  @Deprecated("This function is not run periodically anymore, call checkAndUpdateSubDirectories on demand.")
  Future<void> monitorSubDirectoriesPeriodically(
      {Duration interval = _monitorInterval}) async {
    Timer.periodic(interval, (_) => checkAndUpdateSubDirectories());
  }

  /// Check and update subdirectories if there are changes. If a mandatory directory is missing, it will be recreated.
  Future<void> checkAndUpdateSubDirectories() async {
    await _lock.protect(() async {
      try {
        final userDataPath = await getUserDataPath();
        final currentSubDirs = Directory(userDataPath)
            .listSync(recursive: true)
            .whereType<Directory>()
            .map((dir) => p.normalize(dir.path.replaceFirst(
                RegExp('^${RegExp.escape(userDataPath)}[\\\\/]*'), '')))
            .toSet();
        if (currentSubDirs != _allSubDirectories) {
          print(currentSubDirs);
          print(_allSubDirectories);

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
    final path = p.normalize('$userDataPath/$dirDynamicPath');
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
    final path = p.normalize('$userDataPath/$dirDynamicPath');
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
  /// @param category The name of the category (e.g., 'card', 'deck').
  /// @param relativePath The relative path for the category to be deleted, including any desired subdirectories.
  ///
  /// @return A future that completes when the deletion process has finished. If an error occurs during deletion,
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

  Future<bool> doesDynamicDirectoryExist({
    required String category,
    required String relativePath,
  }) async {
    final path = await getDynamicDirectoryAbsolutePath(
        category: category, relativePath: relativePath);
    return await FileTool().doesDirectoryExist(path);
  }

  Future<String> getDynamicDirectoryPath({
    required String category,
    required String relativePath,
  }) async {
    return p.normalize('$category/$relativePath');
  }

  Future<String> getDynamicDirectoryAbsolutePath({
    required String category,
    required String relativePath,
  }) async {
    String userDataPath = await getUserDataPath();
    String dynamicPath = await getDynamicDirectoryPath(
        category: category, relativePath: relativePath);
    return p.normalize('$userDataPath/$dynamicPath');
  }
}
