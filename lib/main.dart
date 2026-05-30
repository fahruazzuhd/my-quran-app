import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_quran/core/di/injection.dart';
import 'package:my_quran/core/theme/app_theme.dart';
import 'package:my_quran/presentation/controllers/home_controller.dart';
import 'package:my_quran/presentation/controllers/player_controller.dart';
import 'package:my_quran/presentation/routes/app_pages.dart';
import 'package:my_quran/presentation/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  Get.put(sl<HomeController>(), permanent: true);
  Get.put(sl<PlayerController>(), permanent: true);
  runApp(const MyQuranApp());
}

class MyQuranApp extends StatelessWidget {
  const MyQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Quran',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.home,
      getPages: AppPages.routes,
    );
  }
}
