import 'dart:io';

void main() {
  final file = File('lib/app/modules/home/views/home_view.dart');
  final lines = file.readAsLinesSync();
  
  final buffer = StringBuffer();
  for (int i = 0; i < 183; i++) {
    if (i == 4) { // Inject imports after get package
      buffer.writeln("import '../widgets/control_panel.dart';");
      buffer.writeln("import '../widgets/floating_object_editor.dart';");
      buffer.writeln("import '../widgets/selection_panel.dart';");
      buffer.writeln("import '../widgets/grafkom_canvas_painter.dart';");
      buffer.writeln("import '../widgets/canvas_overlays.dart';");
      buffer.writeln("import '../../../data/models/canvas_models.dart';");
    }
    buffer.writeln(lines[i]);
  }
  
  file.writeAsStringSync(buffer.toString());
}
