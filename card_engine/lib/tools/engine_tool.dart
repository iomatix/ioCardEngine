import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/cache.dart';
import 'package:flame/sprite.dart';
import 'package:logger/logger.dart';

import '../Exceptions/cache_exception.dart';
import 'file_tool.dart';
import 'image_tool.dart';

///
/// Set of methods to handle Flame engine operations integrated with Card engine.
///
class EngineTool {
  static final EngineTool _instance = EngineTool._internal();

  /// Logger instance for logging within the class.
  static final Logger _logger = Logger();

  /// Reference to the singleton instances of tools.
  final ImageTool _imageTool = ImageTool();
  final FileTool _fileTool = FileTool();

  /// Cache handler from Flame.
  final Images _imagesHandler = Images();

  EngineTool._internal();

  factory EngineTool() {
    return _instance;
  }

  /// Loads a sprite from the specified [File] and caches it in the Flame engine with the given key.
  ///
  /// - [file] The [File] object representing the image file.
  /// - [cacheKeyName] The key used to store the image in the cache.
  /// - [overrideCache] If `true`, existing cache entry with the same key will be overwritten.
  ///
  /// Throws a [CacheException] if the cache contains the key and [overrideCache] is `false`,
  /// or if the image cannot be retrieved from the cache after loading.
  ///
  /// Returns a [Sprite] created from the cached image.
  Future<Sprite> loadSpriteFromFile(
    File file,
    String cacheKeyName, {
    bool overrideCache = false,
  }) async {
    // Check if the cache already contains the key
    if (!overrideCache && _imagesHandler.containsKey(cacheKeyName)) {
      throw CacheException(
        'Cache contains the `$cacheKeyName` key. Set `overrideCache` to true to overwrite it.',
        cacheKeyName: cacheKeyName,
      );
    }

    // Read file bytes
    final Uint8List dataBytes = await _readFileAsUint8List(file);

    // Decode image from bytes
    final ui.Image image = await _imageTool.decodeImageFromList(dataBytes);

    // Add image to cache
    _imagesHandler.add(cacheKeyName, image);

    // Fetch and return sprite from cache
    final ui.Image? cachedImage = _imagesHandler.fromCache(cacheKeyName);
    if (cachedImage == null) {
      throw CacheException(
        'Failed to retrieve image from cache for the `$cacheKeyName` key.',
        cacheKeyName: cacheKeyName,
      );
    }

    return Sprite(cachedImage);
  }

  /// Loads a sprite from the specified [filePath] and caches it in the Flame engine with the given key.
  ///
  /// - [filePath] The string path to the image file.
  /// - [cacheKeyName] The key used to store the image in the cache.
  /// - [overrideCache] If `true`, existing cache entry with the same key will be overwritten.
  ///
  /// Throws a [CacheException] if the cache contains the key and [overrideCache] is `false`,
  /// if the file does not exist, or if the image cannot be retrieved from the cache after loading.
  ///
  /// Returns a [Sprite] created from the cached image.
  Future<Sprite> loadSpriteFromFilePath(
    String filePath,
    String cacheKeyName, {
    bool overrideCache = false,
  }) async {
    // Validate file existence
    final File file = await _fileTool.readFile(filePath);
    if (!await file.exists()) {
      throw CacheException(
        'File does not exist at path: `$filePath`.',
        cacheKeyName: cacheKeyName,
      );
    }

    // Delegate to loadSpriteFromFile
    try {
      return await loadSpriteFromFile(
        file,
        cacheKeyName,
        overrideCache: overrideCache,
      );
    } catch (e, stackTrace) {
      _logger.e(
        "Failed to load sprite from file path: $filePath",
        error: e,
        stackTrace: stackTrace,
      );
      rethrow; // Propagate the exception
    }
  }

  /// Asynchronously reads the contents of a [File] as a [Uint8List].
  ///
  /// - [file] The [File] to be read.
  ///
  /// Throws a [CacheException] if the file cannot be read.
  ///
  /// Returns a [Future<Uint8List>] containing the file's byte data.
  Future<Uint8List> _readFileAsUint8List(File file) async {
    try {
      return await file.readAsBytes();
    } catch (e, stackTrace) {
      _logger.e(
        "Failed to read file: ${file.path}",
        error: e,
        stackTrace: stackTrace,
      );
      throw CacheException(
        'Failed to read file: ${file.path}',
        cacheKeyName: file.path,
      );
    }
  }
}
