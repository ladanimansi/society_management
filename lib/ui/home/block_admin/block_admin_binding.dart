import 'package:get/get.dart';
import 'block_admin_controller.dart';

class BlockAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlockAdminController>(() => BlockAdminController());
  }
}
