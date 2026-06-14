import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_project_flutter/main.dart';

void main() {
  testWidgets('menampilkan halaman grafika komputer', (tester) async {
    await tester.pumpWidget(const GrafkomApp());

    expect(find.text('Grafika Komputer'), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget);
    expect(
      find.textContaining('Geser untuk menjelajah canvas'),
      findsOneWidget,
    );

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    expect(find.text('Object Selection'), findsOneWidget);
    expect(find.text('Pilih objek untuk diedit'), findsOneWidget);
    expect(find.text('Operasi Transformasi'), findsNothing);
    expect(find.text('Titik'), findsWidgets);
    expect(find.text('Garis'), findsWidgets);
    expect(find.text('Benda 2D'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsWidgets);
  });
}
