import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:society_application/constants/app_constants.dart';
import 'package:society_application/routes/app_routes.dart';

class RegistrationController extends GetxController {
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();

  final currentStep = 0.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();

  final isLoading = false.obs;

  // Step 1: Society
  final societiesList = <Map<String, dynamic>>[].obs;
  final selectedSocietyId = RxnString();
  final selectedSocietyName = RxnString();

  // Step 3: Structure
  final blocksMap = <String, dynamic>{}.obs; 
  final availableBlocks = <String>[].obs;
  final availableFloors = <String>[].obs;
  final availableFlats = <String>[].obs;

  final selectedBlock = RxnString();
  final selectedFloor = RxnString();
  final selectedFlat = RxnString();

  @override
  void onInit() {
    super.onInit();
    _fetchSocieties();
  }

  Future<void> _fetchSocieties() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('society_name').get();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        final list = <Map<String, dynamic>>[];
        for (final entry in data.entries) {
          final societyData = Map<dynamic, dynamic>.from(entry.value as Map);
          list.add({
            'id': entry.key.toString(),
            'name': societyData['name']?.toString() ?? 'Unknown Society',
          });
        }
        societiesList.assignAll(list);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch societies: $e');
    }
  }

  Future<void> fetchSocietyStructure(String societyId) async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('society_name/$societyId/blocks').get();
      if (snapshot.exists && snapshot.value is Map) {
        blocksMap.value = Map<String, dynamic>.from(snapshot.value as Map);
        final blocks = blocksMap.keys.toList()..sort();
        availableBlocks.assignAll(blocks);
      } else {
        blocksMap.clear();
        availableBlocks.clear();
      }
      
      // Reset selections
      selectedBlock.value = null;
      selectedFloor.value = null;
      selectedFlat.value = null;
      availableFloors.clear();
      availableFlats.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load society structure');
    }
  }

  void onSocietySelected(String? id, String? name) {
    selectedSocietyId.value = id;
    selectedSocietyName.value = name;
    if (id != null) {
      fetchSocietyStructure(id);
    }
  }

  void onBlockSelected(String? block) {
    selectedBlock.value = block;
    selectedFloor.value = null;
    selectedFlat.value = null;
    availableFlats.clear();

    if (block != null && blocksMap.containsKey(block)) {
      final floorsData = blocksMap[block];
      if (floorsData is Map) {
        final floors = floorsData.keys
          .where((k) => k.toString() != 'admin')
          .map((e) => e.toString())
          .toList()..sort();
        availableFloors.assignAll(floors);
      }
    } else {
      availableFloors.clear();
    }
  }

  void onFloorSelected(String? floor) {
    selectedFloor.value = floor;
    selectedFlat.value = null;

    final block = selectedBlock.value;
    if (block != null && floor != null && blocksMap.containsKey(block)) {
      final floorsData = blocksMap[block];
      if (floorsData is Map && floorsData.containsKey(floor)) {
        final flatsData = floorsData[floor];
        if (flatsData is Map) {
          final flats = <String>[];
          for (final entry in flatsData.entries) {
            final flatInfo = entry.value;
            // Only add un-occupied flats
            if (flatInfo is Map) {
              final status = flatInfo['status'];
              final residentId = flatInfo['residentId'];
              if (residentId == null && status != 'occupied') {
                flats.add(entry.key.toString());
              }
            } else {
              flats.add(entry.key.toString());
            }
          }
          flats.sort();
          availableFlats.assignAll(flats);
        }
      }
    } else {
      availableFlats.clear();
    }
  }

  void nextStep() {
    if (currentStep.value == 0) {
      if (selectedSocietyId.value == null) {
        Get.snackbar('Error', 'Please select a society');
        return;
      }
      currentStep.value++;
    } else if (currentStep.value == 1) {
      if (formKey2.currentState?.validate() == true) {
        currentStep.value++;
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<void> register() async {
    if (selectedSocietyId.value == null) {
      Get.snackbar('Error', 'Please select a society');
      return;
    }
    if (formKey2.currentState?.validate() != true) return;
    if (selectedBlock.value == null || selectedFloor.value == null || selectedFlat.value == null) {
      Get.snackbar('Error', 'Please select all structure details');
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text;
    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();

    isLoading.value = true;
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final uid = credential.user?.uid;
      if (uid == null) {
        throw Exception("Could not get UID after registration");
      }

      // Save to users table
      final databaseRef = FirebaseDatabase.instance
          .ref(AppConstants.usersPath)
          .child(uid);
      await databaseRef.set({
        'email': email,
        'name': name,
        'mobile': mobile,
        'role': 'resident', // or AppConstants.defaultRole
        'societyId': selectedSocietyId.value,
        'block': selectedBlock.value,
        'floor': selectedFloor.value,
        'flat': selectedFlat.value,
      });

      // Update society structure residentId
      final flatRef = FirebaseDatabase.instance
        .ref('society_name/${selectedSocietyId.value}/blocks/${selectedBlock.value}/${selectedFloor.value}/${selectedFlat.value}');
      
      await flatRef.update({
        'residentId': uid,
        'status': 'occupied',
      });

      Get.offAllNamed(AppRoutes.login);
      Get.snackbar('Success', 'Registered successfully');
    } on FirebaseAuthException catch (e) {
       Get.snackbar('Registration Error', e.message ?? 'Authentication failed');
    } catch (e) {
       Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    mobileController.dispose();
    super.onClose();
  }
}
