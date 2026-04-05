import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// --------------------
/// MODELS
/// --------------------
class BlockModel {
  String name;
  List<FloorModel> floors;

  BlockModel({required this.name, required this.floors});
}

class FloorModel {
  int number;
  List<String> flats;

  FloorModel({required this.number, required this.flats});
}

/// --------------------
/// CONTROLLER
/// --------------------
class CreateBuildingController extends GetxController {
  /// TEXTFIELDS (optional if you use auto mode)
  final societyName = TextEditingController();
  final blockCount = TextEditingController();
  final floorCount = TextEditingController();
  final flatPerFloor = TextEditingController();

  /// UI DATA (Manual Mode)
  var blocks = <BlockModel>[].obs;
  String? societyId;

  /// --------------------
  /// UI ACTIONS
  /// --------------------

  void addBlock() {
    String name = String.fromCharCode(65 + blocks.length); // A, B, C
    blocks.add(BlockModel(name: name, floors: []));
  }

  void addFloor(int blockIndex) {
    int floorNumber = blocks[blockIndex].floors.length + 1;

    blocks[blockIndex].floors.add(FloorModel(number: floorNumber, flats: []));

    blocks.refresh();
  }

  void addFlat(int blockIndex, int floorNumber) {
    final floor = blocks[blockIndex].floors.firstWhere(
      (f) => f.number == floorNumber,
    );

    int flatNumber = floor.flats.length + 1;

    String flatNo = "$floorNumber${flatNumber.toString().padLeft(2, '0')}";
    floor.flats.add(flatNo);

    blocks.refresh();
  }

  void removeBlock(int index) {
    if (index != blocks.length - 1) {
      Get.snackbar("Info", "You can delete only the last block");
      return;
    }
    blocks.removeAt(index);
  }

  void removeFloor(int blockIndex, int floorIndex) {
    if (floorIndex != blocks[blockIndex].floors.length - 1) {
      Get.snackbar("Info", "You can delete only the last floor");
      return;
    }
    blocks[blockIndex].floors.removeAt(floorIndex);
    blocks.refresh();
  }

  void removeFlat(int blockIndex, int floorNumber, String flat) {
    final floor = blocks[blockIndex].floors.firstWhere(
      (f) => f.number == floorNumber,
    );

    if (floor.flats.isEmpty || flat != floor.flats.last) {
      Get.snackbar("Info", "You can delete only the last flat");
      return;
    }

    floor.flats.removeLast();
    blocks.refresh();
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['societyId'] != null) {
      societyId = args['societyId'].toString();
      _loadSocietyStructure(societyId!);
    }
  }

  Future<void> _loadSocietyStructure(String id) async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref("society_name/$id")
          .get();
      if (!snapshot.exists || snapshot.value is! Map) return;

      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      societyName.text = (data["name"] ?? "").toString();

      final blocksData = data["blocks"];
      if (blocksData is! Map) {
        blocks.clear();
        return;
      }

      final loadedBlocks = <BlockModel>[];
      final blockEntries = Map<dynamic, dynamic>.from(blocksData).entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));

      for (final blockEntry in blockEntries) {
        final blockName = blockEntry.key.toString();
        final floorsData = blockEntry.value is Map
            ? Map<dynamic, dynamic>.from(blockEntry.value as Map)
            : <dynamic, dynamic>{};

        final loadedFloors = <FloorModel>[];
        final floorEntries = floorsData.entries.toList()
          ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));

        for (final floorEntry in floorEntries) {
          final floorKey = floorEntry.key.toString();
          final number = int.tryParse(floorKey.replaceAll("floor_", ""));
          if (number == null) continue;

          final flatsData = floorEntry.value is Map
              ? Map<dynamic, dynamic>.from(floorEntry.value as Map)
              : <dynamic, dynamic>{};
          final flats = flatsData.keys.map((e) => e.toString()).toList()..sort();

          loadedFloors.add(FloorModel(number: number, flats: flats));
        }

        loadedBlocks.add(BlockModel(name: blockName, floors: loadedFloors));
      }

      blocks.assignAll(loadedBlocks);
    } catch (_) {
      Get.snackbar("Error", "Failed to load society structure");
    }
  }

  /// --------------------
  /// AUTO GENERATE MODE
  /// --------------------
  void generateStructure() {
    final blocksCount = int.tryParse(blockCount.text) ?? 0;
    final floorsCount = int.tryParse(floorCount.text) ?? 0;
    final flatsCount = int.tryParse(flatPerFloor.text) ?? 0;

    if (blocksCount == 0 || floorsCount == 0 || flatsCount == 0) {
      Get.snackbar("Error", "Please enter valid numbers");
      return;
    }

    blocks.clear();

    for (int b = 0; b < blocksCount; b++) {
      String blockName = String.fromCharCode(65 + b);

      List<FloorModel> floors = [];

      for (int f = 1; f <= floorsCount; f++) {
        List<String> flats = [];

        for (int fl = 1; fl <= flatsCount; fl++) {
          String flatNo = "$f${fl.toString().padLeft(2, '0')}";
          flats.add(flatNo);
        }

        floors.add(FloorModel(number: f, flats: flats));
      }

      blocks.add(BlockModel(name: blockName, floors: floors));
    }
  }

  /// --------------------
  /// SAVE TO FIREBASE
  /// --------------------
  Future<void> createBuilding() async {
    final name = societyName.text.trim();

    if (name.isEmpty) {
      Get.snackbar("Error", "Society name required");
      return;
    }

    if (blocks.isEmpty) {
      Get.snackbar("Error", "Please add structure");
      return;
    }

    try {
      final ref = societyId == null
          ? FirebaseDatabase.instance.ref("society_name").push()
          : FirebaseDatabase.instance.ref("society_name/$societyId");
      final currentSocietyId = societyId ?? ref.key;

      if (currentSocietyId == null) {
        Get.snackbar("Error", "Unable to generate society id");
        return;
      }

      final existingSnapshot = await FirebaseDatabase.instance
          .ref("society_name/$currentSocietyId")
          .get();
      Map<dynamic, dynamic> existingData = {};
      if (existingSnapshot.exists && existingSnapshot.value is Map) {
        existingData = Map<dynamic, dynamic>.from(existingSnapshot.value as Map);
      }

      Map<String, dynamic> societyData = {
        "id": currentSocietyId,
        "name": name,
        "type": "building",
        "blocks": {},
        "createdAt":
            existingData["createdAt"] ?? DateTime.now().toIso8601String(),
        "updatedAt": DateTime.now().toIso8601String(),
      };

      if (existingData["admin"] is Map) {
        societyData["admin"] = Map<dynamic, dynamic>.from(
          existingData["admin"] as Map,
        );
      }

      for (var block in blocks) {
        Map<String, dynamic> floorMap = {};

        for (var floor in block.floors) {
          Map<String, dynamic> flatMap = {};

          for (var flat in floor.flats) {
            flatMap[flat] = {"status": "empty", "residentId": null};
          }

          floorMap["floor_${floor.number}"] = flatMap;
        }

        societyData["blocks"][block.name] = floorMap;
      }

      await ref.set(societyData);
      societyId = currentSocietyId;

      Get.back();
      Get.snackbar("Success", "Society saved successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to create society");
    }
  }

  /// --------------------
  /// CLEANUP
  /// --------------------
  @override
  void onClose() {
    societyName.dispose();
    blockCount.dispose();
    floorCount.dispose();
    flatPerFloor.dispose();
    super.onClose();
  }
}
