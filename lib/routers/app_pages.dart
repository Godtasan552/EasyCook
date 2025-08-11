import 'package:get/get.dart';
import 'app_routes.dart';

import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';

class AppPages {
  AppPages._();

  static final routes = [
    // Splash Screen
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // อนาคตสามารถเพิ่ม routes อื่นๆ ได้ที่นี่
    /*
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeScreen(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    */
  ];
}
