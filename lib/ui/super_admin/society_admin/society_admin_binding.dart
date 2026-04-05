import 'package:get/get.dart';
import 'society_admin_controller.dart';

class SocietyAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SocietyAdminController>(() => SocietyAdminController());
  }
}
