import 'package:get/get.dart';

enum FillType { flood }

class FillAreaHubController extends GetxController {
  final activeFill = FillType.flood.obs;

  void changeFill(FillType type) {
    activeFill.value = type;
  }
}
