import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:easycook/routers/app_pages.dart';
import 'package:easycook/routers/app_routes.dart';
import 'theme/app_theme.dart';

// localization
import 'utils/app_translations.dart';
import 'services/translation_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Form Validate App',

      // Localization Setup (เพิ่ม)
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),

      // Routing ตามของเดิม
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Page Not Found',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('The page you are looking for does not exist.'),
              ],
            ),
          ),
        ),
      ),

      // Theme ตามของเดิม
      theme: AppTheme.LightTheme,

      // Initial Binding (เพิ่ม)
      initialBinding: AppBinding(),
    );
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TranslationService(), permanent: true);
  }
}
