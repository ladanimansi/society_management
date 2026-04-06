import 'package:get/get.dart';
import 'package:society_application/routes/app_routes.dart';

class SuperAdminHomeController extends GetxController {
  void selectBuilding() {
    Get.toNamed(AppRoutes.createBuilding);
  }

  void selectTenament() {
    Get.toNamed(AppRoutes.createTenament);
  }

  void openSocietyAdmins() {
    Get.toNamed(AppRoutes.societyAdmin);
  }
}
