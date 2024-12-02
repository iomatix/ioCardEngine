import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/painting.dart';

import 'package:flame/cache.dart';
import 'package:flame/sprite.dart';

import '../Exceptions/cache_exception.dart';
import '../Exceptions/file_not_found_exception.dart';
import 'file_tool.dart';

///
/// Set of methods to handle flame engine operations integrated to card engine.
///
class EngineTool {
  static final EngineTool _instance = EngineTool._internal();
  final Images _imagesHandler = Images();

  EngineTool._internal();

  factory EngineTool() {
    return _instance;
  }

  /// Loads a sprite from the specified file and caches it in flame engine with the given key.
  ///
  /// [filePath] The path to the image file.
  /// [cacheKeyName] The key used to store the image in the cache.
  /// [overrideCache] If true, existing cache entry with the same key will be overwritten.
  ///
  /// Throws a [CacheException] if the cache contains the key and [overrideCache] is false,
  /// or if the image cannot be retrieved from the cache after loading.
  ///
  /// Returns a [Sprite] created from the cached image.
  Future<Sprite> loadSpriteFromFile(String filePath, String cacheKeyName,
      {bool overrideCache = false}) async {
    // Check the cache if the key is unique
    if (!overrideCache && _imagesHandler.containsKey(cacheKeyName)) {
      throw CacheException(
          'Cache contains the $cacheKeyName key. Set overrideCache to true to overwrite it.',
          cacheKeyName: cacheKeyName);
    }

    // Read file bytes and decode
    final Uint8List dataBytes = await FileTool().openFileAsUint8List(filePath);
    final image = await decodeImageFromList(dataBytes);

    // Add image to cache
    _imagesHandler.add(cacheKeyName, image);
    // Fetch and return sprite from cache

    final cachedImage = _imagesHandler.fromCache(cacheKeyName);
    if (cachedImage == null) {
      throw CacheException('Failed to retrieve image from cache for key',
          cacheKeyName: cacheKeyName);
    }

    return Sprite(cachedImage);
  }
}
