import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:printing/printing.dart';
import 'package:logger/logger.dart';
import 'package:image/image.dart' as img;

import '../Exceptions/file_format_exception.dart';
import '../Exceptions/image_size_does_not_match_exception.dart';
import '../tools/image_tool.dart';

///
/// Set of methods to handle PDF files.
///
class PdfTool {
  static final PdfTool _instance = PdfTool._internal();

  /// Logger instance for logging within the class.
  static final Logger _logger = Logger();

  final ImageTool _imageTool = ImageTool();

  PdfTool._internal();

  factory PdfTool() {
    return _instance;
  }

  /// Converts a PDF file to a list of images.
  ///
  /// This function takes a PDF file in the form of a [Uint8List] and converts
  /// each page into an image. The conversion process can be customized using
  /// optional parameters:
  /// - [dpi]: Specifies the resolution of the output images. Default is 72.
  /// - [limitPages]: Limits the number of pages to convert. A negative value
  ///   means all pages will be converted. Default is -1.
  /// - [requireConstantSize]: Ensures all images have the same size. If set to
  ///   true and a page's size differs, an exception is thrown. Default is true.
  ///
  /// Returns a [Future] that resolves to a list of [img.Image] objects representing
  /// the pages of the PDF.
  ///
  /// Throws:
  /// - [FileFormatException] if the PDF file format is invalid.
  /// - [ImageSizeDoesNotMatchException] if page sizes differ and [requireConstantSize] is true.
  /// - Any exceptions thrown by the [printing] package during rasterization.
  Future<List<img.Image>> convertPdfToImages(
    Uint8List pdfData, {
    double dpi = 72,
    int limitPages = -1,
    bool requireConstantSize = true,
  }) async {
    final List<ui.Image> rawImages = [];
    final List<img.Image> images = [];

    // Validate file format
    if (!_isValidPdf(pdfData)) {
      _logger.e("Invalid PDF file format.");
      throw FileFormatException('The provided data is not a valid PDF.');
    }

// Convert PDF to images
    try {
      ui.Image? prevPage; // To store the previous page for size comparison
      int pagesProcessed = 0;

      await for (final page in Printing.raster(pdfData, dpi: dpi)) {
        if (limitPages >= 0 && pagesProcessed >= limitPages) {
          break; // Stop processing if the limit is reached
        }

        final ui.Image image = await page.toImage();

        // Check for constant size if required
        if (requireConstantSize && prevPage != null) {
          if (!_imageTool.isSizeEqual(prevPage, image)) {
            throw ImageSizeDoesNotMatchException(
              'Page ${pagesProcessed + 1} size does not match the previous page.',
            );
          }
        }

        prevPage = image; // Update reference for comparison
        rawImages.add(image); // Store the image for later processing
        pagesProcessed++;
      }
    } catch (e, stackTrace) {
      _logger.e("Error during PDF to image conversion.",
          error: e, stackTrace: stackTrace);
      rethrow; // Let the caller handle the exception
    }

    // Convert UI images to img.Image
    try {
      for (final uiImage in rawImages) {
        final img.Image convertedImage =
            await _imageTool.convertUiImageToImage(uiImage);
        images.add(convertedImage);
      }
    } catch (e, stackTrace) {
      _logger.e("Error during conversion from dart.ui.Image to img.Image.",
          error: e, stackTrace: stackTrace);

      rethrow; // Propagate the exception
    } finally {
      // Dispose any remaining UI images in case of error
      for (var uiImage in rawImages) {
        uiImage.dispose();
      }
    }

    return images;
  }

  /// Checks if the provided byte array represents a valid PDF file.
  ///
  /// Compares the first few bytes of the input with the standard PDF header
  /// ("%PDF" in ASCII) to determine validity.
  ///
  /// Returns `true` if the byte array starts with the PDF header, otherwise `false`.
  bool _isValidPdf(Uint8List bytes) {
    const List<int> pdfHeader = [0x25, 0x50, 0x44, 0x46]; // "%PDF"

    if (bytes.length < pdfHeader.length) {
      return false;
    }

    for (int i = 0; i < pdfHeader.length; i++) {
      if (bytes[i] != pdfHeader[i]) {
        return false;
      }
    }
    return true;
  }

  /// Converts a list of PDF files to a list of images.
  ///
  /// This asynchronous method reads each PDF file, converts its pages to images,
  /// and aggregates all the images into a single list.
  ///
  /// Args:
  ///   pdfFiles (List<File>): A list of PDF files to be converted.
  ///
  /// Returns:
  ///   Future<List<img.Image>>: A future that resolves to a list of images
  ///   extracted from the PDF files.
  ///
  /// Throws:
  /// - Any exceptions thrown by [convertPdfToImages] for individual PDFs.
  Future<List<img.Image>> convertPdfFilesToImages(List<File> pdfFiles) async {
    final List<img.Image> allImages = [];

    // Process all PDF files concurrently
    await Future.wait(pdfFiles.map((pdfFile) async {
      try {
        final Uint8List fileBytes = await pdfFile.readAsBytes();
        final List<img.Image> images = await convertPdfToImages(fileBytes);
        allImages.addAll(images);
      } catch (e, stackTrace) {
        _logger.e(
          "Failed to convert PDF file: ${pdfFile.path}",
          error: e,
          stackTrace: stackTrace,
        );
        // Optionally, decide whether to continue processing other files
        // or rethrow the exception. Here, we continue processing.
      }
    }));

    return allImages;
  }
}
