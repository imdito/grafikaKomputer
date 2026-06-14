import 'package:get/get.dart';

import 'mixins/canvas_state_mixin.dart';
import 'mixins/canvas_properties_mixin.dart';
import 'mixins/canvas_transform_mixin.dart';
import 'mixins/canvas_drawing_mixin.dart';

class HomeController extends GetxController
    with
        CanvasStateMixin,
        CanvasPropertiesMixin,
        CanvasTransformMixin,
        CanvasDrawingMixin {}
