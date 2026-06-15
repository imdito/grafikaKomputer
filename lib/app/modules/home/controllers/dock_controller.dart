import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DockController extends GetxController {
  final isToolPanelVisible = false.obs;
  bool wasPanelVisibleBeforeDrag = false;

  /// Custom floating position of the tool panel.
  /// If null, it will center-bottom align.
  final panelPosition = Rxn<Offset>();
}
