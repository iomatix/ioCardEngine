import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:printing/printing.dart';
import 'package:logger/logger.dart';
import 'package:image/image.dart' as img;

import '../tools/image_tool.dart';

///
/// Set of methods to handle PDF files.
///
class PdfTool {
  PdfTool();

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
  /// Returns a [Future] that resolves to a list of [Image] objects representing
  /// the pages of the PDF.
  ///
  /// Throws an exception if the PDF file format is invalid or if the page sizes
  /// do not match when [requireConstantSize] is true.
  static Future<List<img.Image>> convertPdfToImages(Uint8List pdfData,
      [double dpi = 72,
      int limitPages = -1,
      bool requireConstantSize = true]) async {
    List<ui.Image> rawImages = [];
    List<img.Image> images = [];
    var logger = Logger();

    // Validate file format
    try {
      if (_isValidPdf(pdfData)) {
        throw Exception('Invalid file format');
      }
    } catch (err) {
      logger.f("The file format is not .PDF.", error: err);
      return images;
    }

    // Convert PDF to images
    try {
      ui.Image? prevPage;
      await for (var page in Printing.raster(pdfData, dpi: dpi)) {
        if (limitPages == 0) {
          break;
        } else {
          limitPages--;
        }
        final ui.Image image = await page.toImage();

        // Throw exception if image sizes do not match
        if (prevPage != null) {
          if (requireConstantSize && !ImageTool.isSizeEqual(prevPage, image)) {
            throw Exception(
                'The size of the page does not match previous page.');
          }
          prevPage.dispose();
        }

        prevPage = image.clone();
        rawImages.add(image.clone());
      }
      if (prevPage != null) {
        prevPage.dispose();
      }
    } catch (err) {
      logger.f("Error during PDF to image conversion.", error: err);
      return images;
    }

    // convert UI images to Images
    try {
      for (ui.Image im in rawImages) {
        img.Image tempImg = await ImageTool.convertUiImageToImage(im);
        images.add(tempImg.clone());
        im.dispose();
      }
    } catch (err) {
      logger.f("Error during image dart.ui to Image conversion.", error: err);
    }

    return images;
  }

  /// Checks if the provided byte array represents a valid PDF file.
  ///
  /// Compares the first few bytes of the input with the standard PDF header
  /// ("%PDF" in hex) to determine validity.
  ///
  /// Returns `true` if the byte array starts with the PDF header, otherwise `false`.
  static bool _isValidPdf(Uint8List bytes) {
    const pdfHeader = [0x25, 0x50, 0x44, 0x46]; // "%PDF" in hex
    for (int i = 0; i < pdfHeader.length; i++) {
      if (bytes[i] != pdfHeader[i]) {
        return false;
      }
    }
    return true;
  }
}
