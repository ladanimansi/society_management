import 'package:get/get.dart';
import 'society_admin_home_controller.dart';

class SocietyAdminHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SocietyAdminHomeController>(
      () => SocietyAdminHomeController(),
    );
  }
}