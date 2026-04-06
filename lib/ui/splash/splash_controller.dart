import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  void onStartPressed() {
    Get.offAllNamed(AppRoutes.login);
  }
}
