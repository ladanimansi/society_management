import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'society_admin_dashboard_controller.dart';
import '../society_admin/society_admin_home_view.dart';
import '../society_admin_activities/society_admin_activities_view.dart';
import '../society_admin_profile/society_admin_profile_view.dart';
import '../../../theme/color.dart';

class SocietyAdminDashboardView extends GetView<SocietyAdminDashboardController> {
  const SocietyAdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const SocietyAdminHomeView(),
      const SocietyAdminActivitiesView(),
      const SocietyAdminProfileView(),
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: 'SOCIETY_ADMIN-NAV_HOME'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.local_activity),
                label: 'SOCIETY_ADMIN-NAV_ACTIVITIES'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: 'SOCIETY_ADMIN-NAV_PROFILE'.tr,
              ),
            ],
          )),
    );
  }
}

