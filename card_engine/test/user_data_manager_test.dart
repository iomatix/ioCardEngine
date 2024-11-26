// user_data_manager_test.dart

import 'dart:io';

import 'package:card_engine/services/user_data_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/path_provider'); // Mock path_provider

  TestWidgetsFlutterBinding
      .ensureInitialized(); // Ensure that the bindings has been initialized correctly.

  group('UserDataManager Test', () {
    const category = '_test_UserDataManager';
    const placeholderRelativePath = 'mock/placeholder';
    const newDirectoryRelativePaths = [
      'mock1',
      'mock2',
      'mock2/mock2_subfolder',
    ];

    setUp(() async {
      // Additional setup goes here.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            // Return a temporary directory path for the test
            return Directory.systemTemp.path;
          }
          return null;
        },
      );
    });

    tearDown(() {
      // Remove the mock after each test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('createDynamicDirectory() creates a directory', () async {
      {
        final udmInstance = UserDataManager();
        await udmInstance.createDynamicDirectory(
            category: category, relativePath: newDirectoryRelativePaths[0]);

        expect(
            await udmInstance.doesDynamicDirectoryExist(
                category: category, relativePath: newDirectoryRelativePaths[0]),
            isTrue);
      }
    });

    test('createDynamicDirectory() does not overwrite existing directories',
        () async {
      final udmInstance = UserDataManager();

      // First call: Create the directory
      await udmInstance.createDynamicDirectory(
          category: category, relativePath: newDirectoryRelativePaths[1]);

      // Second call: Ensure the directory doesn't get overwritten and no error is thrown
      await udmInstance.createDynamicDirectory(
          category: category, relativePath: newDirectoryRelativePaths[1]);

      // Assert that the directory still exists (and wasn't overwritten)
      expect(
          await udmInstance.doesDynamicDirectoryExist(
              category: category, relativePath: newDirectoryRelativePaths[1]),
          isTrue);
    });

    test('deleteDynamicDirectory() removes a directory', () async {
      final udmInstance = UserDataManager();

      await udmInstance.createDynamicDirectory(
          category: category, relativePath: placeholderRelativePath);

      expect(
          await udmInstance.doesDynamicDirectoryExist(
              category: category, relativePath: placeholderRelativePath),
          isTrue);

      await udmInstance.deleteDynamicDirectory(
          category: category, relativePath: placeholderRelativePath);

      expect(
          await udmInstance.doesDynamicDirectoryExist(
              category: category, relativePath: placeholderRelativePath),
          isFalse);
    });
  });
}
