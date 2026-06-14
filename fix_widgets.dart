import 'dart:io';

void main() {
  final filesToFix = [
    'lib/app/modules/home/views/home_view.dart',
    'lib/app/modules/home/widgets/control_panel.dart',
    'lib/app/modules/home/widgets/floating_object_editor.dart',
    'lib/app/modules/home/widgets/selection_panel.dart',
    'lib/app/modules/home/widgets/grafkom_canvas_painter.dart',
    'lib/app/modules/home/widgets/canvas_overlays.dart',
  ];

  final replacements = {
    '_ControlPanel': 'ControlPanel',
    '_FloatingObjectEditor': 'FloatingObjectEditor',
    '_TransformPanel': 'TransformPanel',
    '_SelectionPanel': 'SelectionPanel',
    '_CanvasHint': 'CanvasHint',
    '_CanvasNavigationHint': 'CanvasNavigationHint',
    '_ObjectCounter': 'ObjectCounter',
    '_ToolSelector': 'ToolSelector',
    '_ColorSelector': 'ColorSelector',
    '_FillInput': 'FillInput',
    '_PointInput': 'PointInput',
    '_LineInput': 'LineInput',
    '_ShapeInput': 'ShapeInput',
    '_NumberField': 'NumberField',
    '_SliderRow': 'SliderRow',
    '_shapeTypeName': 'shapeTypeName',
  };

  for (final path in filesToFix) {
    final file = File(path);
    if (!file.existsSync()) continue;

    var content = file.readAsStringSync();
    
    // Replace private widget names with public ones
    for (final entry in replacements.entries) {
      content = content.replaceAll(entry.key, entry.value);
    }
    
    // Add specific imports
    if (path.contains('control_panel.dart')) {
      if (!content.contains("import 'selection_panel.dart';")) {
        content = "import 'selection_panel.dart';\n" + content;
      }
      if (!content.contains("import 'canvas_overlays.dart';")) { // shapeTypeName is there
        content = "import 'canvas_overlays.dart';\n" + content;
      }
    }
    if (path.contains('floating_object_editor.dart')) {
      if (!content.contains("import 'control_panel.dart';")) {
        content = "import 'control_panel.dart';\n" + content;
      }
    }
    if (path.contains('grafkom_canvas_painter.dart')) {
      if (!content.contains("import 'dart:typed_data';")) {
        content = "import 'dart:typed_data';\n" + content;
      }
    }

    file.writeAsStringSync(content);
  }
}
