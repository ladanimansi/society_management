import 'package:get/get.dart';
import 'resident_home_controller.dart';

class ResidentHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResidentHomeController>(() => ResidentHomeController());
  }
}
