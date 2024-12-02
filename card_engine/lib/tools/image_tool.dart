import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';

import '../Exceptions/image_decoding_exception.dart';
import '../Exceptions/image_processing_exception.dart';

///
/// Set of methods to handle image files.
///
class ImageTool {
  static final ImageTool _instance = ImageTool._internal();

  ImageTool._internal();

  factory ImageTool() {
    return _instance;
  }

// This function asynchronously loads an image from Uint8List data.
// It returns a Future<img.Image?> which resolves with the decoded image or null if there's an error.
  static Future<img.Image?> loadImage(Uint8List imageData) async {
    // Initialize logger for logging errors during image decoding.
    var logger = Logger();

    try {
      // Decode the byte data to image using compute function for better performance and type safety.
      return await compute(img.decodeImage, imageData);
    } catch (err) {
      // If an error occurs during image decoding, log it with the provided message and rethrow the exception.
      logger.f("Something gone wrong. The image data seems to be corrupted.",
          error: err);
    }

    // This return statement is unreachable due to the early returns from the try block or the catch block.
    // It's here for null safety purposes, as the function has a declared return type of Future
    return null;
  }

  /// Converts a ui.Image into an img.Image.
  ///
  /// This function takes a ui.Image as input and converts it into an img.Image object. It first obtains the byte data from the ui.Image,
  /// then decodes that byte data to create the new img.Image object.
  ///
  /// @param uiImage The ui.Image to be converted.
  ///
  /// @return A future that completes with the converted img.Image object.
  static Future<img.Image> convertUiImageToImage(ui.Image uiImage) async {
    var logger = Logger();
    img.Image image = img.Image(width: uiImage.width, height: uiImage.height);

    try {
      // Obtain the byte data from the ui.Image
      final ByteData? byteData =
          await uiImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List uint8list = byteData!.buffer.asUint8List();

      // Decode the byte data to image
      image = img.decodeImage(uint8list)!;
    } catch (err) {
      logger.f("Error during image dart.ui to Image conversion.", error: err);
    }

    return image;
  }

  /// Checks if two `Image` objects have the same dimensions.
  ///
  /// @param firstImage The first image to compare.
  /// @param secondImage The second image to compare.
  /// @return True if both images have the same width and height, false otherwise.
  static bool isSizeEqual(ui.Image firstImage, ui.Image secondImage) {
    // Check if either the width or height of the two images differ
    if (firstImage.width != secondImage.width ||
        firstImage.height != secondImage.height) {
      return false;
    }
    // If both dimensions are equal for both images, return true
    return true;
  }

  /// Asynchronously retrieves the size of a PNG image located at the specified path.
  ///
  /// @param path The file path of the PNG image.
  /// @return A `Future` containing a `Size` object with the width and height of the image, or throws an exception if decoding fails.
  static Future<ui.Size> getPngSize(String path) async {
    // Read the contents of the file at the specified path
    final file = File(path);

    try {
      // Decode the PNG image from the bytes read from the file
      final image = img.decodeImage(file.readAsBytesSync());

      // If decoding was successful, return a Size object with the width and height of the image
      if (image != null) {
        return ui.Size(image.width.toDouble(), image.height.toDouble());
      } else {
        // If decoding failed, throw an exception
        throw ImageDecodingException('Failed to decode image');
      }
    } catch (e) {
      // Handle any errors that occurred during file reading or decoding
      throw ImageProcessingException('Error processing image: $e');
    }
  }
}
