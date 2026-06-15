import 'package:get/get.dart';
import 'line_controller.dart';

/// Dependency Injection binding for the Line Tool.
class LineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LineController>(() => LineController());
  }
}
