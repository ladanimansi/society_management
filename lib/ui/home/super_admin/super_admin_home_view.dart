import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:society_application/routes/app_routes.dart';
import '../../../common_widgets/custom_app_bar.dart';
import '../../../theme/color.dart';
import 'super_admin_home_controller.dart';

class SuperAdminHomeView extends GetView<SuperAdminHomeController> {
  const SuperAdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'SUPER_ADMIN-TITLE', showLogout: true),

      // ✅ Floating Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showCreateSocietyOptions(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SUPER_ADMIN-ALL_SOCIETIES".tr,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: controller.openSocietyAdmins,
                icon: const Icon(Icons.manage_accounts),
                label: Text('SUPER_ADMIN-MANAGE_SOCIETY_ADMINS'.tr),
              ),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance.ref().onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text("SUPER_ADMIN-FAILED_LOAD_SOCIETIES".tr),
                    );
                  }

                  final rootValue = snapshot.data?.snapshot.value;
                  if (rootValue == null || rootValue is! Map) {
                    return Center(child: Text("SUPER_ADMIN-NO_SOCIETIES".tr));
                  }

                  final rootMap = Map<dynamic, dynamic>.from(rootValue);
                  final societiesValue = rootMap['society_name'];
                  if (societiesValue == null || societiesValue is! Map) {
                    return Center(child: Text("SUPER_ADMIN-NO_SOCIETIES".tr));
                  }

                  final societyAdminsValue = rootMap['society_admins'];
                  final societyAdminsMap = societyAdminsValue is Map
                      ? Map<dynamic, dynamic>.from(societyAdminsValue)
                      : <dynamic, dynamic>{};

                  final Map<String, List<String>> activeAdminsBySociety = {};
                  for (final adminEntry in societyAdminsMap.entries) {
                    if (adminEntry.value is! Map) continue;
                    final adminData = Map<dynamic, dynamic>.from(
                      adminEntry.value as Map,
                    );
                    if (adminData['isActive'] != true) continue;

                    final societyId = (adminData['societyId'] ?? '')
                        .toString()
                        .trim();
                    if (societyId.isEmpty) continue;

                    final adminName = (adminData['name'] ?? '')
                        .toString()
                        .trim();
                    final adminMobile = (adminData['mobile'] ?? '')
                        .toString()
                        .trim();

                    if (adminName.isEmpty) continue;

                    final label = adminMobile.isEmpty
                        ? adminName
                        : '$adminName • $adminMobile';

                    activeAdminsBySociety.putIfAbsent(societyId, () => []);
                    activeAdminsBySociety[societyId]!.add(label);
                  }

                  final entries = Map<dynamic, dynamic>.from(
                    societiesValue,
                  ).entries.toList().reversed.toList();

                  return ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final item = entries[index];
                      final itemData = item.value is Map
                          ? Map<dynamic, dynamic>.from(item.value as Map)
                          : <dynamic, dynamic>{};

                      final societyName =
                          (itemData['name']?.toString().trim().isNotEmpty ??
                              false)
                          ? itemData['name'].toString()
                          : "SUPER_ADMIN-UNNAMED_SOCIETY".tr;
                      final societyId = item.key.toString();
                      final activeAdmins =
                          activeAdminsBySociety[societyId] ?? <String>[];
                      final adminText = activeAdmins.isEmpty
                          ? 'SUPER_ADMIN-ADMIN_NOT_ASSIGNED'.tr
                          : activeAdmins.join('\n');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Get.toNamed(
                            AppRoutes.createBuilding,
                            arguments: {'societyId': item.key.toString()},
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  child: const Icon(
                                    Icons.apartment,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        societyName,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        adminText,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: activeAdmins.isEmpty
                                                  ? Colors.redAccent
                                                  : Colors.green,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 Bottom Sheet for Type Selection
  void _showCreateSocietyOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "SUPER_ADMIN-SELECT_SOCIETY_TYPE".tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              // 🏢 Building Option
              _optionTile(
                icon: Icons.apartment,
                title: "SUPER_ADMIN-BUILDING".tr,
                onTap: () {
                  Get.back();
                  controller.selectBuilding();
                },
              ),

              const SizedBox(height: 12),

              // 🏠 Tenament Option
              _optionTile(
                icon: Icons.home,
                title: "SUPER_ADMIN-TENAMENT_BUNGALOW".tr,
                onTap: () {
                  Get.back();
                  controller.selectTenament();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: AppColors.primaryLight.withOpacity(0.1),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: onTap,
    );
  }
}
