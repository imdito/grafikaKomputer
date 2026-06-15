import 'package:get/get.dart';
import 'translate_controller.dart';

class TranslateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TranslateController>(() => TranslateController());
  }
}
