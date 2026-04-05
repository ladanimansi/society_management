import 'package:get/get.dart';
import 'create_tenament_controller.dart';

class CreateTenamentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateTenamentController>(() => CreateTenamentController());
  }
}
