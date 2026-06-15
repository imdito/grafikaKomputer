import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/canvas_models.dart';
class SelectionPanel extends StatelessWidget {
  const SelectionPanel({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final options = controller.objectOptions;
    final selectedRef = controller.selectedObject.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.ads_click, size: 18),
            const SizedBox(width: 8),
            Text(
              'Object Selection',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<CanvasObjectRef>(
          initialValue: selectedRef,
          decoration: const InputDecoration(
            labelText: 'Pilih objek untuk diedit',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option.ref,
              child: Text(option.label),
            );
          }).toList(),
          onChanged: controller.selectObject,
        ),
        if (options.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Belum ada objek. Buat titik, garis, atau benda 2D terlebih dahulu.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (selectedRef != null) ...[
          const SizedBox(height: 8),
          Text(
            'Panel edit mengambang di dekat objek terpilih pada canvas.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

