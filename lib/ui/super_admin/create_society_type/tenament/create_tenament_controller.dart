import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateTenamentController extends GetxController {
  final societyName = TextEditingController();
  final sectorCount = TextEditingController();
  final housePerSector = TextEditingController();

  Future<void> createTenament() async {
    final name = societyName.text.trim();
    final sectors = int.parse(sectorCount.text);
    final houses = int.parse(housePerSector.text);

    final ref = FirebaseDatabase.instance.ref("societies").push();

    Map<String, dynamic> data = {
      "name": name,
      "type": "tenament",
      "sectors": {}
    };

    for (int s = 0; s < sectors; s++) {
      String sectorName = String.fromCharCode(65 + s); // A, B, C

      Map<String, dynamic> houseMap = {};

      for (int h = 1; h <= houses; h++) {
        houseMap["house_$h"] = {"status": "empty"};
      }

      data["sectors"][sectorName] = houseMap;
    }

    await ref.set(data);

    Get.back();
    Get.snackbar("Success", "Tenament created");
  }
}