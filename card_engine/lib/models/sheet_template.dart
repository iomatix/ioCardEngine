import 'package:uuid/uuid.dart';

import '../types/margin.dart';


class SheetTemplate {
  final String id;
  final String name;

  final Margin margin;
  final Margin innerMargin;
  final bool hasReverses;

  final int columns;
  final int rows;


  SheetTemplate({
    required this.name,
    required this.margin,
    required this.innerMargin,
    required this.hasReverses,
    required this.columns,
    required this.rows,
  }) : id = Uuid().v4(){
      // custom body
  }


}