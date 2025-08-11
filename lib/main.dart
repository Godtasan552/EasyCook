import 'package:easycook/routers/app_pages.dart';
import 'package:easycook/routers/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';

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

      // กำหนด initial route เป็น Splash Screen
      initialRoute: AppRoutes.SPLASH,

      // กำหนด pages และ routes
      getPages: AppPages.routes,

      // กำหนด route ที่ไม่พบ
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
      theme: AppTheme.LightTheme,
    );
  }
}
