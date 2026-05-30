import 'package:get/get.dart';
import 'package:my_quran/core/di/injection.dart';
import 'package:my_quran/presentation/controllers/home_controller.dart';
import 'package:my_quran/presentation/pages/home_page.dart';
import 'package:my_quran/presentation/pages/player_page.dart';
import 'package:my_quran/presentation/routes/app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => sl<HomeController>());
      }),
    ),
    GetPage(
      name: AppRoutes.player,
      page: () => const PlayerPage(),
    ),
  ];
}
