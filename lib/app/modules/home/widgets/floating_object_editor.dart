import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import 'object_editor/primitive_attributes_panel.dart';
import 'object_editor/transform_panel.dart';

/// Panel melayang (Floating) yang digunakan untuk mengedit atribut dan transformasi
/// dari objek yang sedang dipilih (selected) di atas canvas.
class FloatingObjectEditor extends StatelessWidget {
  const FloatingObjectEditor({required this.controller});

  /// Referensi ke HomeController
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      color: Theme.of(context).colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_location_alt_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.selectedObjectLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup editor',
                    onPressed: () => controller.selectObject(null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              PrimitiveAttributesPanel(controller: controller, enabled: true),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              TransformPanel(controller: controller, enabled: true),
            ],
          ),
        ),
      ),
    );
  }
}
