abstract class AppRoutes {
  AppRoutes._();

  static const SPLASH = '/';
  static const BKK = '/bkk';
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const FORGET_PASSWORD = '/forget-password';
  static const PROFILE = '/profile';

  static String getSplashRoute() => SPLASH;
  static String getBkkRoute() => BKK;
  static String getHomeRoute() => HOME;
  // ... อื่นๆ
}
