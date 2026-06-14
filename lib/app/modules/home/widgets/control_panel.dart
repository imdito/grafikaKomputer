import 'canvas_overlays.dart';
import 'selection_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/canvas_models.dart';
class ControlPanel extends StatelessWidget {
  const ControlPanel({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectionPanel(controller: controller),
                const Divider(height: 28),
                ToolSelector(controller: controller),
                const SizedBox(height: 12),
                ColorSelector(controller: controller),
                const SizedBox(height: 12),
                switch (controller.selectedTool.value) {
                  DrawingTool.point => PointInput(controller: controller),
                  DrawingTool.line => LineInput(controller: controller),
                  DrawingTool.shape => ShapeInput(controller: controller),
                  DrawingTool.fill => FillInput(controller: controller),
                  DrawingTool.pen => PenInput(controller: controller),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ToolSelector extends StatelessWidget {
  const ToolSelector({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildChip(DrawingTool.point, 'Titik', Icons.circle),
          _buildChip(DrawingTool.line, 'Garis', Icons.show_chart),
          _buildChip(DrawingTool.shape, 'Benda 2D', Icons.category_outlined),
          _buildChip(DrawingTool.fill, 'Fill Warna', Icons.format_color_fill),
          _buildChip(DrawingTool.pen, 'Pen', Icons.draw),
        ],
      );
    });
  }

  Widget _buildChip(DrawingTool tool, String label, IconData icon) {
    final isSelected = controller.selectedTool.value == tool;
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) controller.changeTool(tool);
      },
    );
  }
}

class ColorSelector extends StatelessWidget {
  const ColorSelector({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Warna:'),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                Color currentColor = controller.selectedColor.value;
                return AlertDialog(
                  title: const Text('Pilih Warna'),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: currentColor,
                      onColorChanged: (color) {
                        currentColor = color;
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Simpan'),
                      onPressed: () {
                        controller.changeColor(currentColor);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: controller.selectedColor.value,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueGrey, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FillInput extends StatelessWidget {
  const FillInput({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mewarnai Area (Flood Fill)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Pilih warna global di atas, lalu tutup menu ini dan TAP di area tertutup mana saja (termasuk potongan benda/garis berpotongan) di canvas.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        SliderRow(
          label: 'Opacity',
          value: controller.shapeOpacity.value,
          min: 0.1,
          max: 1,
          divisions: 9,
          displayValue: '${(controller.shapeOpacity.value * 100).round()}%',
          onChanged: controller.changeShapeOpacity,
        ),
      ],
    );
  }
}

class PointInput extends StatelessWidget {
  const PointInput({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Input Titik Manual',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: NumberField(
                controller: controller.xController,
                label: 'X',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.yController,
                label: 'Y',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.radiusController,
                label: 'Radius',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: controller.addPointFromInput,
            icon: const Icon(Icons.add),
            label: const Text('Buat Titik'),
          ),
        ),
      ],
    );
  }
}

class LineInput extends StatelessWidget {
  const LineInput({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Input Garis Manual',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SegmentedButton<LineAlgorithm>(
          segments: const [
            ButtonSegment(value: LineAlgorithm.dda, label: Text('DDA')),
            ButtonSegment(
              value: LineAlgorithm.bresenham,
              label: Text('Bresenham'),
            ),
          ],
          selected: {controller.selectedAlgorithm.value},
          onSelectionChanged: (selection) {
            controller.changeAlgorithm(selection.first);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: NumberField(
                controller: controller.x1Controller,
                label: 'X1',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.y1Controller,
                label: 'Y1',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.x2Controller,
                label: 'X2',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.y2Controller,
                label: 'Y2',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderRow(
          label: 'Tebal',
          value: controller.strokeWidth.value,
          min: 1,
          max: 16,
          divisions: 15,
          displayValue: controller.strokeWidth.value.toStringAsFixed(0),
          onChanged: controller.changeStrokeWidth,
        ),
        SliderRow(
          label: 'Opacity',
          value: controller.lineOpacity.value,
          min: 0.1,
          max: 1,
          divisions: 9,
          displayValue: '${(controller.lineOpacity.value * 100).round()}%',
          onChanged: controller.changeLineOpacity,
        ),
        Row(
          children: [
            const Text('Gaya Garis:'),
            const SizedBox(width: 8),
            DropdownButton<StrokeStyle>(
              value: controller.lineStyle.value,
              items: const [
                DropdownMenuItem(value: StrokeStyle.solid, child: Text('Solid')),
                DropdownMenuItem(value: StrokeStyle.dashed, child: Text('Dashed')),
                DropdownMenuItem(value: StrokeStyle.dotted, child: Text('Dotted')),
              ],
              onChanged: (style) {
                if (style != null) controller.changeLineStyle(style);
              },
            ),
            const Spacer(),
            if (controller.pendingLineStart.value != null)
              TextButton.icon(
                onPressed: controller.cancelPendingLine,
                icon: const Icon(Icons.close),
                label: const Text('Batal titik awal'),
              ),
            const Spacer(),
            FilledButton.icon(
              onPressed: controller.addLineFromInput,
              icon: const Icon(Icons.add),
              label: const Text('Buat Garis'),
            ),
          ],
        ),
      ],
    );
  }
}

class ShapeInput extends StatelessWidget {
  const ShapeInput({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Input Benda 2D',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ShapeType>(
          initialValue: controller.selectedShapeType.value,
          decoration: const InputDecoration(
            labelText: 'Jenis benda',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: ShapeType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(shapeTypeName(type)),
            );
          }).toList(),
          onChanged: (type) {
            if (type != null) {
              controller.changeShapeType(type);
            }
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: NumberField(
                controller: controller.shapeXController,
                label: 'X pusat',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.shapeYController,
                label: 'Y pusat',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.shapeWidthController,
                label: 'Lebar',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.shapeHeightController,
                label: 'Tinggi',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderRow(
          label: 'Outline',
          value: controller.shapeStrokeWidth.value,
          min: 1,
          max: 16,
          divisions: 15,
          displayValue: controller.shapeStrokeWidth.value.toStringAsFixed(0),
          onChanged: controller.changeShapeStrokeWidth,
        ),
        SliderRow(
          label: 'Opacity',
          value: controller.shapeOpacity.value,
          min: 0.1,
          max: 1,
          divisions: 9,
          displayValue: '${(controller.shapeOpacity.value * 100).round()}%',
          onChanged: controller.changeShapeOpacity,
        ),
        Row(
          children: [
            const Text('Isi warna'),
            Switch(
              value: controller.isFilledShape.value,
              onChanged: controller.toggleFilledShape,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: controller.addShapeFromInput,
              icon: const Icon(Icons.add),
              label: const Text('Buat Benda'),
            ),
          ],
        ),
      ],
    );
  }
}

class NumberField extends StatelessWidget {
  const NumberField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

class SliderRow extends StatelessWidget {
  const SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 64, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: displayValue,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(displayValue, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

class PenInput extends StatelessWidget {
  const PenInput({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menggambar Coretan Bebas (Pen)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Sentuh dan tahan (drag) pada canvas untuk menggambar coretan bebas secara langsung.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        SliderRow(
          label: 'Tebal',
          value: controller.strokeWidth.value,
          min: 1,
          max: 16,
          divisions: 15,
          displayValue: controller.strokeWidth.value.toStringAsFixed(0),
          onChanged: controller.changeStrokeWidth,
        ),
        SliderRow(
          label: 'Opacity',
          value: controller.lineOpacity.value,
          min: 0.1,
          max: 1,
          divisions: 9,
          displayValue: '${(controller.lineOpacity.value * 100).round()}%',
          onChanged: controller.changeLineOpacity,
        ),
        Row(
          children: [
            const Text('Gaya Garis:'),
            const SizedBox(width: 8),
            DropdownButton<StrokeStyle>(
              value: controller.lineStyle.value,
              items: const [
                DropdownMenuItem(value: StrokeStyle.solid, child: Text('Solid')),
                DropdownMenuItem(value: StrokeStyle.dashed, child: Text('Dashed')),
                DropdownMenuItem(value: StrokeStyle.dotted, child: Text('Dotted')),
              ],
              onChanged: (style) {
                if (style != null) controller.changeLineStyle(style);
              },
            ),
          ],
        ),
      ],
    );
  }
}
