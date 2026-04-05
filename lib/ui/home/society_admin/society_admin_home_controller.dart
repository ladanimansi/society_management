import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SocietyAdminBlock {
  String name;
  List<SocietyAdminFloor> floors;

  SocietyAdminBlock({required this.name, required this.floors});
}

class SocietyAdminFloor {
  int number;
  List<String> flats;

  SocietyAdminFloor({required this.number, required this.flats});
}

class SocietyAdminHomeController extends GetxController {
  final societyName = TextEditingController();

  final isLoading = true.obs;
  final blocks = <SocietyAdminBlock>[].obs;
  String? societyId;

  @override
  void onInit() {
    super.onInit();
    _loadMySociety();
  }

  Future<void> _loadMySociety() async {
    isLoading.value = true;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        Get.snackbar('Error', 'Login required');
        return;
      }

      final userSnapshot = await FirebaseDatabase.instance.ref('users/$uid').get();
      if (!userSnapshot.exists || userSnapshot.value is! Map) {
        Get.snackbar('Error', 'User data not found');
        return;
      }

      final userData = Map<dynamic, dynamic>.from(userSnapshot.value as Map);
      societyId = userData['societyId']?.toString();
      if (societyId == null || societyId!.isEmpty) {
        Get.snackbar('Error', 'No society assigned to this admin');
        return;
      }

      final societySnapshot = await FirebaseDatabase.instance
          .ref('society_name/$societyId')
          .get();
      if (!societySnapshot.exists || societySnapshot.value is! Map) {
        Get.snackbar('Error', 'Society data not found');
        return;
      }

      final data = Map<dynamic, dynamic>.from(societySnapshot.value as Map);
      societyName.text = (data['name'] ?? '').toString();

      final blocksData = data['blocks'];
      if (blocksData is! Map) {
        blocks.clear();
        return;
      }

      final loaded = <SocietyAdminBlock>[];
      final blockEntries = Map<dynamic, dynamic>.from(blocksData).entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));

      for (final blockEntry in blockEntries) {
        final floorsData = blockEntry.value is Map
            ? Map<dynamic, dynamic>.from(blockEntry.value as Map)
            : <dynamic, dynamic>{};
        final floors = <SocietyAdminFloor>[];

        final floorEntries = floorsData.entries.toList()
          ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));

        for (final floorEntry in floorEntries) {
          final floorKey = floorEntry.key.toString();
          final floorNumber = int.tryParse(floorKey.replaceAll('floor_', ''));
          if (floorNumber == null) continue;

          final flatsData = floorEntry.value is Map
              ? Map<dynamic, dynamic>.from(floorEntry.value as Map)
              : <dynamic, dynamic>{};
          final flats = flatsData.keys.map((e) => e.toString()).toList()..sort();
          floors.add(SocietyAdminFloor(number: floorNumber, flats: flats));
        }

        loaded.add(
          SocietyAdminBlock(name: blockEntry.key.toString(), floors: floors),
        );
      }

      blocks.assignAll(loaded);
    } catch (_) {
      Get.snackbar('Error', 'Failed to load society structure');
    } finally {
      isLoading.value = false;
    }
  }

  void addBlock() {
    String name = String.fromCharCode(65 + blocks.length);
    blocks.add(SocietyAdminBlock(name: name, floors: []));
  }

  void addFloor(int blockIndex) {
    final floorNumber = blocks[blockIndex].floors.length + 1;
    blocks[blockIndex].floors.add(
      SocietyAdminFloor(number: floorNumber, flats: []),
    );
    blocks.refresh();
  }

  void addFlat(int blockIndex, int floorNumber) {
    final floor = blocks[blockIndex].floors.firstWhere(
      (f) => f.number == floorNumber,
    );
    final flatNumber = floor.flats.length + 1;
    final flatNo = "$floorNumber${flatNumber.toString().padLeft(2, '0')}";
    floor.flats.add(flatNo);
    blocks.refresh();
  }

  void removeBlock(int index) {
    if (index != blocks.length - 1) {
      Get.snackbar('Info', 'You can delete only the last block');
      return;
    }
    blocks.removeAt(index);
  }

  void removeFloor(int blockIndex, int floorIndex) {
    if (floorIndex != blocks[blockIndex].floors.length - 1) {
      Get.snackbar('Info', 'You can delete only the last floor');
      return;
    }
    blocks[blockIndex].floors.removeAt(floorIndex);
    blocks.refresh();
  }

  void removeFlat(int blockIndex, int floorNumber, String flat) {
    final floor = blocks[blockIndex].floors.firstWhere(
      (f) => f.number == floorNumber,
    );
    if (floor.flats.isEmpty || floor.flats.last != flat) {
      Get.snackbar('Info', 'You can delete only the last flat');
      return;
    }
    floor.flats.removeLast();
    blocks.refresh();
  }

  Future<void> saveMySocietyStructure() async {
    if (societyId == null || societyId!.isEmpty) {
      Get.snackbar('Error', 'No society assigned');
      return;
    }
    if (societyName.text.trim().isEmpty) {
      Get.snackbar('Error', 'Society name missing');
      return;
    }
    if (blocks.isEmpty) {
      Get.snackbar('Error', 'Please add structure');
      return;
    }

    try {
      final ref = FirebaseDatabase.instance.ref('society_name/$societyId');
      final existingSnapshot = await ref.get();
      Map<dynamic, dynamic> existingData = {};
      if (existingSnapshot.exists && existingSnapshot.value is Map) {
        existingData = Map<dynamic, dynamic>.from(existingSnapshot.value as Map);
      }

      final societyData = <String, dynamic>{
        'id': societyId,
        'name': societyName.text.trim(),
        'type': existingData['type'] ?? 'building',
        'blocks': <String, dynamic>{},
        'createdAt': existingData['createdAt'] ?? DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (existingData['admin'] is Map) {
        societyData['admin'] = Map<dynamic, dynamic>.from(
          existingData['admin'] as Map,
        );
      }

      for (final block in blocks) {
        final floorMap = <String, dynamic>{};
        for (final floor in block.floors) {
          final flatMap = <String, dynamic>{};
          for (final flat in floor.flats) {
            flatMap[flat] = {'status': 'empty', 'residentId': null};
          }
          floorMap['floor_${floor.number}'] = flatMap;
        }
        (societyData['blocks'] as Map<String, dynamic>)[block.name] = floorMap;
      }

      await ref.set(societyData);
      Get.snackbar('Success', 'Society structure saved');
    } catch (_) {
      Get.snackbar('Error', 'Failed to save structure');
    }
  }

  @override
  void onClose() {
    societyName.dispose();
    super.onClose();
  }
}