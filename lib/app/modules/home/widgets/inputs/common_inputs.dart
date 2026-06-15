import 'package:flutter/material.dart';

/// Komponen input teks khusus untuk angka (X, Y, Lebar, Tinggi, dll).
class NumberField extends StatelessWidget {
  const NumberField({required this.controller, required this.label});

  /// Controller untuk field teks
  final TextEditingController controller;

  /// Label teks
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}

/// Komponen baris slider dengan label di kiri dan nilai di kanan.
/// Digunakan untuk mengatur opacity, ketebalan outline, dll.
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

  /// Label teks di sisi kiri slider
  final String label;

  /// Nilai saat ini dari slider
  final double value;

  /// Nilai minimum slider
  final double min;

  /// Nilai maksimum slider
  final double max;

  /// Jumlah langkah diskrit pada slider
  final int divisions;

  /// Teks nilai yang ditampilkan di sisi kanan slider
  final String displayValue;

  /// Fungsi callback ketika nilai slider diubah
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
