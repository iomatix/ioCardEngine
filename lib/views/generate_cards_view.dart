import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:card_engine/tools/tools.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:logger/logger.dart';
import 'package:image/image.dart' as img;

import 'package:card_engine/tools/file_tool.dart';
import 'package:card_engine/tools/image_tool.dart';
import 'package:card_engine/tools/pdf_tool.dart';

/// Provider for Logger instance.
final loggerProvider = Provider<Logger>((ref) => Logger());

/// Provider for Tool instances.
final toolsProvider = Provider<Tools>((ref) => Tools());

/// Main widget for generating cards.
class GenerateCardsView extends ConsumerStatefulWidget {
  @override
  _GenerateCardsViewState createState() => _GenerateCardsViewState();
}

class _GenerateCardsViewState extends ConsumerState<GenerateCardsView> {
  /// List of selected image and PDF files.
  List<File> selectedFiles = [];

  /// List of images extracted from PDFs.
  List<ui.Image> pdfImages = [];

  /// List of directly selected image files as ui.Image.
  List<ui.Image> imageFiles = [];

  /// Parameters adjusted by the user.
  double parameterValue = 0.0; // Example parameter.

  // Define allowed extensions.
  final List<String> _allowedExtensionsImages = [
    'jpg',
    'jpeg',
    'png',
    'bmp',
    'tiff',
    'webp'
  ];
  final List<String> _allowedExtensionsPdfs = ['pdf'];

  /// Initiates file selection.
  Future<void> selectFiles() async {
    final logger = ref.read(loggerProvider);
    final tools = ref.read(toolsProvider);

    try {
      // Open file picker.
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          ..._allowedExtensionsImages,
          ..._allowedExtensionsPdfs
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        List<File> validFiles = [];

        for (var file in files) {
          final mimeType = lookupMimeType(file.path);

          if (mimeType == null) {
            logger
                .w("Could not determine the MIME type for file: ${file.path}");
            continue; // Skip files with undetermined MIME types.
          }

          if (_isPdfExtension(file.path)) {
            if (mimeType == 'application/pdf') {
              validFiles.add(file);
            } else {
              logger.w("Invalid PDF file type: ${file.path}");
              _showErrorDialog(
                  context, 'Selected file is not a valid PDF: ${file.path}');
            }
          } else if (_isImageExtension(file.path)) {
            if (mimeType.startsWith('image/')) {
              validFiles.add(file);
            } else {
              logger.w("Invalid image file type: ${file.path}");
              _showErrorDialog(
                  context, 'Selected file is not a valid image: ${file.path}');
            }
          } else {
            logger.w("Unsupported file type: ${file.path}");
            _showErrorDialog(
                context, 'Unsupported file type selected: ${file.path}');
          }
        }

        if (validFiles.isEmpty) {
          logger.i("No valid files selected for processing.");
          return;
        }

        setState(() {
          selectedFiles = validFiles;
        });

        // Process selected files.
        await _processSelectedFiles(validFiles);
      } else {
        // User canceled the picker.
        logger.i("File selection canceled by the user.");
      }
    } catch (e, stackTrace) {
      logger.e("Error during file selection.",
          error: e, stackTrace: stackTrace);
      _showErrorDialog(context, "An error occurred during file selection: $e");
    }
  }

  /// Processes the list of selected files.
  Future<void> _processSelectedFiles(List<File> files) async {
    try {
      for (var file in files) {
        if (_isPdfExtension(file.path)) {
          await _convertPdfToImages(file);
        } else if (_isImageExtension(file.path)) {
          await _addImageFile(file);
        }
      }
    } catch (e, stackTrace) {
      final logger = ref.read(loggerProvider);
      logger.e("Error during processing of selected files.",
          error: e, stackTrace: stackTrace);
      _showErrorDialog(context, "An error occurred during file processing: $e");
    }
  }

  /// Converts a PDF file to images and updates the state.
  Future<void> _convertPdfToImages(File pdfFile) async {
    final logger = ref.read(loggerProvider);
    final tools = ref.read(toolsProvider);

    try {
      List<img.Image> pdfImagesList =
          await tools.pdfTool.convertPdfToImages(await pdfFile.readAsBytes());

      if (pdfImagesList.isEmpty) {
        throw Exception(
            'No images were extracted from the PDF: ${pdfFile.path}');
      }

      for (var imgImage in pdfImagesList) {
        final ui.Image uiImage =
            await tools.imageTool.convertImgImageToUiImage(imgImage);
        setState(() {
          pdfImages.add(uiImage);
        });
      }

      logger.i("Converted PDF to images successfully: ${pdfFile.path}");
    } catch (e, stackTrace) {
      logger.e("Error during PDF to images conversion.",
          error: e, stackTrace: stackTrace);
      _showErrorDialog(context,
          "Failed to convert PDF to images: ${pdfFile.path}\nError: $e");
    }
  }

  /// Adds an image file to the state by converting it to ui.Image.
  Future<void> _addImageFile(File imageFile) async {
    final logger = ref.read(loggerProvider);
    final tools = ref.read(toolsProvider);

    try {
      img.Image? imgImage =
          await tools.imageTool.loadImage(await imageFile.readAsBytes());
      if (imgImage == null) {
        throw Exception('Failed to load image: ${imageFile.path}');
      }

      final ui.Image uiImage =
          await tools.imageTool.convertImgImageToUiImage(imgImage);
      setState(() {
        imageFiles.add(uiImage);
      });

      logger.i("Loaded image successfully: ${imageFile.path}");
    } catch (e, stackTrace) {
      logger.e("Error during image loading.", error: e, stackTrace: stackTrace);
      _showErrorDialog(
          context, "Failed to load image: ${imageFile.path}\nError: $e");
    }
  }

  /// Checks if the file has an image extension.
  bool _isImageExtension(String path) {
    String extension = path.split('.').last.toLowerCase();
    return _allowedExtensionsImages.contains(extension);
  }

  /// Checks if the file has a PDF extension.
  bool _isPdfExtension(String path) {
    String extension = path.split('.').last.toLowerCase();
    return _allowedExtensionsPdfs.contains(extension);
  }

  /// Displays an error dialog with the provided message.
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(child: Text(message)),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Builds the main UI.
  @override
  Widget build(BuildContext context) {
    final tools = ref.watch(toolsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Cards'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // File Selection Button
              ElevatedButton.icon(
                onPressed: selectFiles,
                icon: Icon(Icons.upload_file),
                label: Text("Select Files (Images/PDFs)"),
              ),
              SizedBox(height: 20),

              // Display selected images
              if (imageFiles.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selected Images:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: imageFiles.map((uiImage) {
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: RawImage(
                            image: uiImage,
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                  ],
                ),

              // Display PDF converted images
              if (pdfImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PDF Pages:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: pdfImages.map((uiImage) {
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: RawImage(
                            image: uiImage,
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                  ],
                ),

              // Parameters Adjustment Slider
              if (imageFiles.isNotEmpty || pdfImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Adjust Parameters:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: parameterValue,
                      min: 0.0,
                      max: 100.0,
                      divisions: 100,
                      label: parameterValue.round().toString(),
                      onChanged: (double newValue) {
                        setState(() {
                          parameterValue = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 20),

                    // Custom Painter Example
                    SizedBox(
                      height: 200,
                      child: CustomPaint(
                        painter: OverlayPainter(parameterValue),
                        child: Container(),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter to render overlays based on parameter values.
class OverlayPainter extends CustomPainter {
  final double parameterValue;

  OverlayPainter(this.parameterValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Example: Draw a red rectangle.
    canvas.drawRect(
        Rect.fromLTWH(20, 20, size.width - 40, size.height - 40), paint);

    // Conditionally draw green grid based on parameterValue.
    if (parameterValue > 50) {
      final gridPaint = Paint()
        ..color = Colors.green.withOpacity(0.5)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      // Draw vertical lines every 50 pixels.
      for (double x = 0; x <= size.width; x += 50) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }

      // Draw horizontal lines every 50 pixels.
      for (double y = 0; y <= size.height; y += 50) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant OverlayPainter oldDelegate) {
    return parameterValue != oldDelegate.parameterValue;
  }
}

/// Helper function to decode images using the `compute` function for background processing.
img.Image? _decodeImage(Uint8List imageData) {
  try {
    return img.decodeImage(imageData);
  } catch (e) {
    return null;
  }
}
