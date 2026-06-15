import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../controllers/dock_controller.dart';
import '../../../../features/output_primitives/line_tool/line_binding.dart';
import '../../../../features/output_primitives/point_tool/point_binding.dart';
import '../../../../features/output_primitives/pen_tool/pen_controller.dart';
import '../../../../features/output_primitives/shape_tool/shape_controller.dart';
import '../../../../features/fill_area/fill_area_hub_binding.dart';
import '../../../../features/attributes/object_selection/select_controller.dart';
import '../../../../features/transformations/rotate/rotate_controller.dart';
import '../../../../features/transformations/scale/scale_controller.dart';
import '../../../../features/transformations/shear/shear_controller.dart';
import '../../../../features/transformations/translate/translate_controller.dart';
import '../../../../features/output_primitives/curve_tool/curve_binding.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DockController>(() => DockController());
    LineBinding().dependencies();
    PointBinding().dependencies();
    CurveBinding().dependencies();
    Get.lazyPut<PenController>(() => PenController());
    Get.lazyPut<ShapeController>(() => ShapeController());
    FillAreaHubBinding().dependencies();
    Get.lazyPut<SelectController>(() => SelectController());
    Get.lazyPut<TranslateController>(() => TranslateController());
    Get.lazyPut<ScaleController>(() => ScaleController());
    Get.lazyPut<RotateController>(() => RotateController());
    Get.lazyPut<ShearController>(() => ShearController());
  }
}
