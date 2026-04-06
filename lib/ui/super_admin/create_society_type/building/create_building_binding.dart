import 'package:get/get.dart';
import 'create_building_controller.dart';

class CreateBuildingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateBuildingController>(
      () => CreateBuildingController(),
    );
  }
}