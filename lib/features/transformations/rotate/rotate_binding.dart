import 'package:get/get.dart';
import 'rotate_controller.dart';

/// Dependency Injection binding for the Rotate Tool.
class RotateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RotateController>(() => RotateController());
  }
}
