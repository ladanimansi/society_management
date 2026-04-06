import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:society_application/common_widgets/custom_text_field.dart';
import 'package:society_application/theme/color.dart';
import 'society_admin_controller.dart';

class SocietyAdminView extends GetView<SocietyAdminController> {
  const SocietyAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOCIETY_ADMIN-LIST_TITLE'.tr),
        backgroundColor: AppColors.primary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          controller.prepareCreate();
          _openAdminForm(context);
        },
        icon: const Icon(Icons.person_add),
        label: Text('SOCIETY_ADMIN-ADD_ADMIN'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.admins.isEmpty) {
          return Center(child: Text('SOCIETY_ADMIN-NO_ADMIN'.tr));
        }

        final Map<String, List<SocietyAdminModel>> groupedAdmins = {};
        for (final admin in controller.admins) {
          final key = admin.societyName.isEmpty
              ? 'SOCIETY_ADMIN-UNASSIGNED'.tr
              : admin.societyName;
          groupedAdmins.putIfAbsent(key, () => []);
          groupedAdmins[key]!.add(admin);
        }
        final societyGroups = groupedAdmins.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: societyGroups.length,
          itemBuilder: (context, index) {
            final group = societyGroups[index];
            final societyName = group.key;
            final admins = group.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.apartment, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          societyName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '${admins.length} ${admins.length > 1 ? 'SOCIETY_ADMIN-ADMIN_COUNT_MULTI'.tr : 'SOCIETY_ADMIN-ADMIN_COUNT_SINGLE'.tr}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...admins.map((admin) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                        ),
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
                                  style: Theme.of(context).textTheme.titleSmall,
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
                          Text('${'SOCIETY_ADMIN-MOBILE'.tr}: ${admin.mobile}'),
                          Text('${'SOCIETY_ADMIN-EMAIL'.tr}: ${admin.email}'),
                          Row(
                            children: [
                              Text(
                                admin.isActive
                                    ? 'COMMON-ACTIVE'.tr
                                    : 'COMMON-INACTIVE'.tr,
                                style: TextStyle(
                                  color: admin.isActive
                                      ? Colors.green
                                      : Colors.red,
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
                  }),
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
                  DropdownButtonFormField<String>(
                    value: controller.selectedSocietyId.value,
                    decoration: InputDecoration(
                      labelText: 'SOCIETY_ADMIN-SELECT_SOCIETY'.tr,
                      border: const OutlineInputBorder(),
                    ),
                    items: controller.societies
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item['id'],
                            child: Text(item['name'] ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        controller.selectedSocietyId.value = value,
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
