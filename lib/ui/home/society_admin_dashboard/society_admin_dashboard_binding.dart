import 'package:get/get.dart';
import 'society_admin_dashboard_controller.dart';
import '../society_admin/society_admin_home_controller.dart';
import '../society_admin_activities/society_admin_activities_controller.dart';
import '../society_admin_profile/society_admin_profile_controller.dart';

class SocietyAdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SocietyAdminDashboardController>(
      () => SocietyAdminDashboardController(),
    );
    
    // Inject controllers for the sub-pages
    Get.lazyPut<SocietyAdminHomeController>(
      () => SocietyAdminHomeController(),
    );
    
    Get.lazyPut<SocietyAdminActivitiesController>(
      () => SocietyAdminActivitiesController(),
    );

    Get.lazyPut<SocietyAdminProfileController>(
      () => SocietyAdminProfileController(),
    );
  }
}

