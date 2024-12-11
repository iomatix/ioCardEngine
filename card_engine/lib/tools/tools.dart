import 'package:card_engine/tools/file_tool.dart';
import 'package:card_engine/tools/image_tool.dart';
import 'package:card_engine/tools/pdf_tool.dart';

/// Helper class to encapsulate tool instances.
class Tools {
  final PdfTool pdfTool = PdfTool();
  final FileTool fileTool = FileTool();
  final ImageTool imageTool = ImageTool();
}