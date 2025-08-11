import 'package:easycook/routers/app_routes.dart';
import 'package:get/get.dart';

import '../screens/splash_screen.dart';
import '../screens/brk.dart';
import '../screens/home_screen.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.BKK,
      page: () => const BkkScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // ... เพิ่มเติม routes ตามต้องการ
  ];
}
