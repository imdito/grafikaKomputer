import 'dart:io';

void main() {
  final file = File('lib/app/modules/home/views/home_view.dart');
  final lines = file.readAsLinesSync();
  
  void writeFile(String name, List<List<int>> ranges) {
    final out = File('lib/app/modules/home/widgets/$name');
    final buffer = StringBuffer();
    
    buffer.writeln("import 'package:flutter/material.dart';");
    buffer.writeln("import 'package:get/get.dart';");
    buffer.writeln("import '../controllers/home_controller.dart';");
    buffer.writeln("import '../../../data/models/canvas_models.dart';");
    
    for (final range in ranges) {
      for (int i = range[0] - 1; i < range[1]; i++) {
        if (i < lines.length) {
          buffer.writeln(lines[i]);
        }
      }
    }
    out.writeAsStringSync(buffer.toString());
  }

  Directory('lib/app/modules/home/widgets').createSync(recursive: true);

  // control_panel.dart
  writeFile('control_panel.dart', [
    [184, 223], // _ControlPanel
    [509, 546], // _ToolSelector
    [547, 582], // _ColorSelector
    [583, 616], // _FillInput
    [617, 669], // _PointInput
    [670, 774], // _LineInput
    [775, 879], // _ShapeInput
    [880, 899], // _NumberField
    [900, 942], // _SliderRow
  ]);

  // floating_object_editor.dart
  writeFile('floating_object_editor.dart', [
    [284, 333], // _FloatingObjectEditor
    [334, 508], // _TransformPanel
  ]);

  // selection_panel.dart
  writeFile('selection_panel.dart', [
    [224, 283], // _SelectionPanel
  ]);

  // grafkom_canvas_painter.dart
  writeFile('grafkom_canvas_painter.dart', [
    [943, 1256], // GrafkomCanvasPainter
  ]);

  // canvas_overlays.dart
  writeFile('canvas_overlays.dart', [
    [1257, 1286], // _CanvasHint
    [1287, 1312], // _CanvasNavigationHint
    [1313, lines.length], // _ObjectCounter
  ]);
}
