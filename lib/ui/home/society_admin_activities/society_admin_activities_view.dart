import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'society_admin_activities_controller.dart';
import '../../../common_widgets/custom_app_bar.dart';
import '../../../theme/color.dart';

class SocietyAdminActivitiesView extends GetView<SocietyAdminActivitiesController> {
  const SocietyAdminActivitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'SOCIETY_ADMIN-NAV_ACTIVITIES'.tr,
        showBackButton: false,
        showLogout: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_activity, size: 80, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your activities will appear here.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
