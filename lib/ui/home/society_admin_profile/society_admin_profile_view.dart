import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'society_admin_profile_controller.dart';
import '../../../common_widgets/custom_app_bar.dart';
import '../../../common_widgets/custom_text_field.dart';
import '../../../theme/color.dart';

class SocietyAdminProfileView extends GetView<SocietyAdminProfileController> {
  const SocietyAdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'SOCIETY_ADMIN-NAV_PROFILE'.tr,
        showBackButton: false,
        showLogout: true,
      ),
      floatingActionButton: Obx(() {
        if (controller.mySocietyId.value == null) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          onPressed: () {
            controller.prepareCreate();
            _openAdminForm(context);
          },
          icon: const Icon(Icons.person_add),
          label: Text('SOCIETY_ADMIN-ADD_ADMIN'.tr),
        );
      }),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.mySocietyId.value == null) {
          return const Center(child: Text("You are not assigned to a society."));
        }
        if (controller.admins.isEmpty) {
          return Center(child: Text('SOCIETY_ADMIN-NO_ADMIN'.tr));
        }

        final admins = controller.admins;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: admins.length,
          itemBuilder: (context, index) {
            final admin = admins[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 16,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          admin.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          controller.prepareEdit(admin);
                          _openAdminForm(context);
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${'SOCIETY_ADMIN-MOBILE'.tr}: ${admin.mobile}'),
                  const SizedBox(height: 4),
                  Text('${'COMMON-EMAIL'.tr}: ${admin.email}'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        admin.isActive
                            ? 'COMMON-ACTIVE'.tr
                            : 'COMMON-INACTIVE'.tr,
                        style: TextStyle(
                          color: admin.isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: admin.isActive,
                        onChanged: (value) =>
                            controller.toggleAdminStatus(admin, value),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _openAdminForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Obx(
            () => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.editingAdminId.value == null
                        ? 'SOCIETY_ADMIN-CREATE_ADMIN'.tr
                        : 'SOCIETY_ADMIN-EDIT_ADMIN'.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: controller.nameController,
                    labelText: 'SOCIETY_ADMIN-ADMIN_NAME'.tr,
                    hintText: 'SOCIETY_ADMIN-ENTER_ADMIN_NAME'.tr,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: controller.mobileController,
                    labelText: 'SOCIETY_ADMIN-MOBILE_NUMBER'.tr,
                    hintText: 'SOCIETY_ADMIN-ENTER_MOBILE_NUMBER'.tr,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: controller.emailController,
                    labelText: 'COMMON-EMAIL'.tr,
                    hintText: 'SOCIETY_ADMIN-ENTER_EMAIL_ADDRESS'.tr,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: controller.passwordController,
                    labelText: 'COMMON-PASSWORD'.tr,
                    hintText: 'SOCIETY_ADMIN-ENTER_PASSWORD'.tr,
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('COMMON-ACTIVE'.tr),
                      const SizedBox(width: 8),
                      Switch(
                        value: controller.isActive.value,
                        onChanged: (value) => controller.isActive.value = value,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: controller.isSaving.value
                          ? null
                          : () async {
                              final done = await controller.saveSocietyAdmin();
                              if (done) {
                                Get.back();
                              }
                            },
                      icon: controller.isSaving.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        controller.isSaving.value
                            ? 'SOCIETY_ADMIN-SAVING'.tr
                            : 'SOCIETY_ADMIN-SAVE_ADMIN'.tr,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
