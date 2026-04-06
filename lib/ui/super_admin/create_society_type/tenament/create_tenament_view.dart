import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:society_application/theme/color.dart';
import 'create_tenament_controller.dart';

class CreateTenamentView extends GetView<CreateTenamentController> {
  const CreateTenamentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Tenament"),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller.societyName,
              decoration: const InputDecoration(labelText: "Society Name"),
            ),

            TextField(
              controller: controller.sectorCount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Number of Sectors"),
            ),

            TextField(
              controller: controller.housePerSector,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Houses per Sector"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: controller.createTenament,
              child: const Text("Create Tenament"),
            ),
          ],
        ),
      ),
    );
  }
}
