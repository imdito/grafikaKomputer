import 'enums.dart';

/// Referensi unik untuk mengidentifikasi objek pada canvas (garis, bentuk, dll)
class CanvasObjectRef {
  const CanvasObjectRef({required this.type, required this.id});

  /// Tipe dari objek (garis, shape, fill, dll)
  final CanvasObjectType type;
  
  /// ID unik objek
  final int id;

  @override
  bool operator ==(Object other) {
    return other is CanvasObjectRef && other.type == type && other.id == id;
  }

  @override
  int get hashCode => Object.hash(type, id);
}

/// Model untuk menampilkan opsi pilihan objek di UI
class CanvasObjectOption {
  const CanvasObjectOption({required this.ref, required this.label});

  /// Referensi objek
  final CanvasObjectRef ref;
  
  /// Label teks yang akan ditampilkan di UI
  final String label;
}
