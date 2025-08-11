import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import 'theme/app_theme.dart';
import 'routers/app_router.dart';
import 'controllers/auth_controller.dart';
import 'controllers/meal_controller.dart';
import 'controllers/user_controller.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await StorageService().init(); // open boxes
  runApp(const EasyCookApp());
}

class EasyCookApp extends StatelessWidget {
  const EasyCookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => MealController()),
      ],
      child: MaterialApp(
        title: 'EasyCook',
        theme: AppTheme.light(),
        initialRoute: AppRouter.login,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
