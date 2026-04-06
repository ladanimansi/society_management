import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:society_application/common_widgets/custom_text_field.dart';
import '../../../common_widgets/custom_app_bar.dart';
import '../../../theme/color.dart';
import '../block_admin/block_admin_controller.dart';
import '../block_admin/block_admin_view.dart';
import 'society_admin_home_controller.dart';

class SocietyAdminHomeView extends GetView<SocietyAdminHomeController> {
  const SocietyAdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'SOCIETY_ADMIN-HOME_TITLE',
        showBackButton: false,
        showLogout: true,
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'saveMySocietyFab',
            backgroundColor: Colors.green,
            onPressed: controller.saveMySocietyStructure,
            icon: const Icon(Icons.save),
            label: Text('COMMON-SAVE'.tr),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'addMySocietyBlockFab',
            backgroundColor: AppColors.primary,
            onPressed: controller.addBlock,
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: CustomTextField(
                controller: controller.societyName,
                labelText: 'BUILDING-SOCIETY_NAME'.tr,
                hintText: 'BUILDING-SOCIETY_NAME'.tr,
                readOnly: true,
                prefixIcon: const Icon(Icons.location_city_outlined),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.blocks.length,
                itemBuilder: (context, index) {
                  final block = controller.blocks[index];
                  final isLastBlock = index == controller.blocks.length - 1;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      title: Text("${'BUILDING-BLOCK'.tr} ${block.name}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${block.floors.length} ${'BUILDING-FLOORS'.tr}'),
                          const SizedBox(height: 4),
                          if (block.activeAdmins.isNotEmpty)
                            ...block.activeAdmins.map((admin) => Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (!Get.isRegistered<BlockAdminController>()) {
                                    Get.put(BlockAdminController());
                                  }
                                  final bController = Get.find<BlockAdminController>();
                                  final model = BlockAdminModel.fromMap(admin['id'], admin);
                                  bController.prepareEdit(model);
                                  BlockAdminView.openAdminForm(context, bController);
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.person, size: 14, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        admin['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 12, 
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (!Get.isRegistered<BlockAdminController>()) {
                                    Get.put(BlockAdminController());
                                  }
                                  final bController = Get.find<BlockAdminController>();
                                  bController.prepareCreate();
                                  bController.selectedBlockName.value = block.name;
                                  BlockAdminView.openAdminForm(context, bController);
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.person_add_alt_1, size: 14, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'BLOCK_ADMIN-UNASSIGNED'.tr,
                                        style: const TextStyle(
                                          fontSize: 12, 
                                          color: Colors.red,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: isLastBlock
                          ? IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => controller.removeBlock(index),
                            )
                          : null,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.add),
                          title: Text('BUILDING-ADD_FLOORS'.tr),
                          onTap: () => controller.addFloor(index),
                        ),
                        ...block.floors.asMap().entries.map((entry) {
                          final floorIndex = entry.key;
                          final floor = entry.value;
                          final isLastFloor =
                              floorIndex == block.floors.length - 1;

                          return ExpansionTile(
                            title: Text("${'BUILDING-FLOOR'.tr} ${floor.number}"),
                            subtitle: Text(
                              '${floor.flats.length} ${'BUILDING-FLATS'.tr}',
                            ),
                            trailing: isLastFloor
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => controller.removeFloor(
                                      index,
                                      floorIndex,
                                    ),
                                  )
                                : null,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.add),
                                title: Text('BUILDING-ADD_FLAT'.tr),
                                onTap: () =>
                                    controller.addFlat(index, floor.number),
                              ),
                              Wrap(
                                spacing: 8,
                                children: floor.flats.asMap().entries.map((
                                  flatEntry,
                                ) {
                                  final flatIndex = flatEntry.key;
                                  final flat = flatEntry.value;
                                  final isLastFlat =
                                      flatIndex == floor.flats.length - 1;
                                  return Chip(
                                    label: Text(flat),
                                    backgroundColor: AppColors.primaryLight
                                        .withOpacity(0.2),
                                    deleteIcon: isLastFlat
                                        ? const Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.red,
                                          )
                                        : null,
                                    onDeleted: isLastFlat
                                        ? () => controller.removeFlat(
                                              index,
                                              floor.number,
                                              flat,
                                            )
                                        : null,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}