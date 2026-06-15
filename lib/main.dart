import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/data/grafkom_theme.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(const GrafkomApp());
}

class GrafkomApp extends StatelessWidget {
  const GrafkomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Aplikasi Grafika Komputer',
      debugShowCheckedModeBanner: false,
      theme: GrafkomTheme.buildTheme(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
