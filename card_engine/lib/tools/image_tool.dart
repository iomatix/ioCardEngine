import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:card_engine/Exceptions/image_decoding_exception.dart';
import 'package:card_engine/Exceptions/image_processing_exception.dart';
import 'package:card_engine/Exceptions/unknown_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';

///
/// Set of methods to handle image files.
///
class ImageTool {
  static final ImageTool _instance = ImageTool._internal();
  static final Logger _logger = Logger();

  ImageTool._internal();

  factory ImageTool() {
    return _instance;
  }

  /// Asynchronously loads an image from Uint8List data.
  ///
  /// Returns a `Future<img.Image>` which resolves with the decoded image
  /// or throws an exception if there's an error.
  Future<img.Image> loadImage(Uint8List imageData) async {
    try {
      final img.Image? image = await compute(_decodeImage, imageData);
      if (image == null) {
        throw ImageDecodingException('Failed to decode image.');
      }
      return image;
    } catch (err, stackTrace) {
      _logger.e(
        "Something went wrong. The image data seems to be corrupted.",
        error: err,
        stackTrace: stackTrace,
      );
      throw UnknownException(
        "Something went wrong with the image processing.",
        cause: err,
        stackTrace: stackTrace,
      );
    }
  }

  /// Converts a [ui.Image] into an [img.Image].
  ///
  /// This function takes a [ui.Image] as input and converts it into an [img.Image] object.
  /// It first obtains the byte data from the [ui.Image], then decodes that byte data
  /// to create the new [img.Image] object.
  ///
  /// @param uiImage The [ui.Image] to be converted.
  ///
  /// @return A `Future` that completes with the converted [img.Image] object.
  ///
  /// Throws:
  /// - [ImageProcessingException] if byte data retrieval fails.
  /// - [ImageDecodingException] if image decoding fails.
  /// - [UnknownException] for any other unforeseen errors.
  Future<img.Image> convertUiImageToImage(ui.Image uiImage) async {
    if (uiImage.width <= 0 || uiImage.height <= 0) {
      throw ImageProcessingException(
          'uiImage has invalid dimensions: ${uiImage.width}x${uiImage.height}.');
    }
    try {
      final ByteData? byteData =
          await uiImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw ImageProcessingException(
            'Failed to retrieve byte data from ui.Image.');
      }
      final Uint8List uint8list = byteData.buffer.asUint8List();

      final img.Image? decodedImage = img.decodeImage(uint8list);
      if (decodedImage == null) {
        throw ImageDecodingException('Failed to decode image.');
      }

      return decodedImage;
    } catch (err, stackTrace) {
      _logger.e(
        "Error during image dart.ui to img.Image conversion.",
        error: err,
        stackTrace: stackTrace,
      );
      throw UnknownException(
        "Failed to convert ui.Image to img.Image.",
        cause: err,
        stackTrace: stackTrace,
      );
    }
  }

  /// Converts an [img.Image] into a [ui.Image].
  ///
  /// This function takes an [img.Image] as input and converts it into a [ui.Image] object.
  /// It first encodes the [img.Image] into PNG byte data, then decodes that byte data
  /// to create the new [ui.Image] object.
  ///
  /// @param imgImage The [img.Image] to be converted.
  ///
  /// @return A `Future` that completes with the converted [ui.Image] object.
  ///
  /// Throws:
  /// - [ImageProcessingException] if image encoding fails.
  /// - [ImageDecodingException] if image decoding fails.
  /// - [UnknownException] for any other unforeseen errors.
  Future<ui.Image> convertImgImageToUiImage(img.Image imgImage) async {
    try {
      // Encode img.Image to PNG
      final Uint8List pngBytes = Uint8List.fromList(img.encodePng(imgImage));

      // Decode PNG bytes to ui.Image
      final ui.Image uiImage = await decodeImageFromList(pngBytes);
      return uiImage;
    } catch (err, stackTrace) {
      _logger.e(
        "Error during image img.Image to ui.Image conversion.",
        error: err,
        stackTrace: stackTrace,
      );
      throw UnknownException(
        "Failed to convert img.Image to ui.Image.",
        cause: err,
        stackTrace: stackTrace,
      );
    }
  }

  /// Checks if two [ui.Image] objects have the same dimensions.
  ///
  /// @param firstImage The first image to compare.
  /// @param secondImage The second image to compare.
  ///
  /// @return `True` if both images have the same width and height, `false` otherwise.
  bool isSizeEqual(ui.Image firstImage, ui.Image secondImage) {
    return firstImage.width == secondImage.width &&
        firstImage.height == secondImage.height;
  }

  /// Asynchronously retrieves the size of an image from a [File].
  ///
  /// This method determines the image format based on the file extension and uses the
  /// appropriate decoder. Supported formats include PNG, JPEG, BMP, and WebP. Additional formats
  /// can be added as needed.
  ///
  /// @param file The [File] object representing the image.
  ///
  /// @return A `Future` containing a [ui.Size] object with the width and height of the image,
  ///         or throws an exception if decoding fails.
  ///
  /// Throws:
  /// - [ImageDecodingException] if the image format is unsupported or corrupted.
  /// - [ImageProcessingException] for any errors during processing.
  Future<ui.Size> getImageSize(File file) async {
    final String extension = _getFileExtension(file).toLowerCase();
    final Uint8List fileBytes = await _readFileAsUint8List(file);

    try {
      img.Image? image;

      switch (extension) {
        case 'png':
          image = img.decodePng(fileBytes);
          break;
        case 'jpg':
        case 'jpeg':
          image = img.decodeJpg(fileBytes);
          break;
        case 'bmp':
          image = img.decodeBmp(fileBytes);
          break;
        case 'webp':
          image = img.decodeWebP(fileBytes);
          break;
        // Add more cases as needed, e.g., 'gif', 'tiff'
        default:
          throw ImageDecodingException(
              'Unsupported file extension: .$extension');
      }

      if (image != null) {
        return ui.Size(image.width.toDouble(), image.height.toDouble());
      }

      throw ImageDecodingException(
          'Failed to decode image: unsupported format or corrupted data.');
    } catch (e, stackTrace) {
      _logger.e(
        "Error processing image: ${file.path}",
        error: e,
        stackTrace: stackTrace,
      );
      throw ImageProcessingException('Error processing image: $e');
    }
  }

  /// Asynchronously reads the contents of a [File] as a [Uint8List].
  ///
  /// - [file] The [File] to be read.
  ///
  /// Throws a [ImageProcessingException] if the file cannot be read.
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
      throw ImageProcessingException('Failed to read file: ${file.path}');
    }
  }

  /// Extracts the file extension from a [File].
  ///
  /// @param file The [File] from which to extract the extension.
  ///
  /// @return The file extension without the dot, or an empty string if none found.
  String _getFileExtension(File file) {
    final String filePath = file.path;
    final int dotIndex = filePath.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < filePath.length - 1) {
      return filePath.substring(dotIndex + 1);
    }
    return '';
  }

  /// Decodes a [ui.Image] from a list of bytes.
  ///
  /// - [dataBytes] The byte data of the image.
  ///
  /// Throws a [ImageDecodingException] if the image cannot be decoded.
  ///
  /// Returns a `Future<ui.Image>` representing the decoded UI image.
  Future<ui.Image> decodeImageFromList(Uint8List dataBytes) async {
    final Completer<ui.Image> completer = Completer();

    try {
      ui.decodeImageFromList(dataBytes, (ui.Image image) {
        completer.complete(image);
      });
    } catch (e, stackTrace) {
      _logger.e(
        "Failed to decode image from byte data.",
        error: e,
        stackTrace: stackTrace,
      );
      completer.completeError(ImageDecodingException(
        'Failed to decode image from byte data.',
      ));
    }

    return completer.future;
  }
}

/// Compresses the given image [imageData] to the target resolution, while maintaining
/// the aspect ratio, and applies the specified [quality] level.
///
/// The function will attempt to resize the image to fit within the [targetWidth] and
/// [targetHeight], while preserving the aspect ratio. If the decoded image cannot
/// be retrieved from the input data, an exception will be thrown.
///
/// [imageData]: The original image data as a [Uint8List].
/// [targetWidth]: The target width to resize the image to.
/// [targetHeight]: The target height to resize the image to.
/// [quality]: The quality of the compressed image, from 0 (low) to 100 (high).
///
/// Returns a [Uint8List] representing the compressed image.
///
/// Throws a [FormatException] if the image could not be decoded.
Future<Uint8List> compressImage(Uint8List imageData, int targetWidth, int targetHeight, int quality) async {
  // Decode the image from the input data
  img.Image? decodedImage = _decodeImage(imageData);

  // Check if the image was successfully decoded
  if (decodedImage == null) {
    throw FormatException('Failed to decode image.');
  }

  // Calculate the aspect ratio of the decoded image
  double aspectRatio = decodedImage.width / decodedImage.height;

  // Calculate the new dimensions to maintain the aspect ratio
  int newWidth = targetWidth;
  int newHeight = (targetWidth / aspectRatio).round();

  // Adjust to fit within the target height if needed
  if (newHeight > targetHeight) {
    newHeight = targetHeight;
    newWidth = (targetHeight * aspectRatio).round();
  }

  // Compress the image with the new dimensions and quality
  return await FlutterImageCompress.compressWithList(
    imageData,
    minWidth: newWidth,
    minHeight: newHeight,
    quality: quality,
  );
}



/// Helper function to decode images using the `compute` function for background processing.
img.Image? _decodeImage(Uint8List imageData) {
  try {
    return img.decodeImage(imageData);
  } catch (e) {
    return null;
  }
}
