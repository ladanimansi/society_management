import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlockAdminModel {
  final String id;
  final String? userUid;
  final String name;
  final String mobile;
  final String email;
  final String password;
  final String societyId;
  final String blockName;
  final bool isActive;
  final String? createdAt;

  const BlockAdminModel({
    required this.id,
    this.userUid,
    required this.name,
    required this.mobile,
    required this.email,
    required this.password,
    required this.societyId,
    required this.blockName,
    required this.isActive,
    this.createdAt,
  });

  factory BlockAdminModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return BlockAdminModel(
      id: id,
      userUid: map['userUid']?.toString(),
      name: (map['name'] ?? '').toString(),
      mobile: (map['mobile'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      password: (map['password'] ?? '').toString(),
      societyId: (map['societyId'] ?? '').toString(),
      blockName: (map['blockName'] ?? '').toString(),
      isActive: map['isActive'] == true,
      createdAt: map['createdAt']?.toString(),
    );
  }
}

class BlockAdminController extends GetxController {
  final _db = FirebaseDatabase.instance.ref();
  StreamSubscription<DatabaseEvent>? _adminSubscription;

  final admins = <BlockAdminModel>[].obs;
  final blocks = <String>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final selectedBlockName = RxnString();
  final isActive = true.obs;
  final editingAdminId = RxnString();

  String? currentSocietyId;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        Get.snackbar('Error', 'Login required');
        isLoading.value = false;
        return;
      }

      final userSnapshot = await _db.child('users/$uid').get();
      if (!userSnapshot.exists || userSnapshot.value is! Map) {
        Get.snackbar('Error', 'User data not found');
        isLoading.value = false;
        return;
      }

      final userData = Map<dynamic, dynamic>.from(userSnapshot.value as Map);
      currentSocietyId = userData['societyId']?.toString();

      if (currentSocietyId == null || currentSocietyId!.isEmpty) {
        Get.snackbar('Error', 'No society assigned');
        isLoading.value = false;
        return;
      }

      await _loadBlocks();
      _listenBlockAdmins();
    } catch (_) {
      isLoading.value = false;
    }
  }

  Future<void> _loadBlocks() async {
    if (currentSocietyId == null) return;
    try {
      final snapshot = await _db.child('society_name/$currentSocietyId/blocks').get();
      if (!snapshot.exists || snapshot.value is! Map) {
        blocks.clear();
        return;
      }
      final map = Map<dynamic, dynamic>.from(snapshot.value as Map);
      final list = map.keys.map((e) => e.toString()).toList();
      list.sort();
      blocks.assignAll(list);
    } catch (_) {
      blocks.clear();
    }
  }

  void _listenBlockAdmins() {
    if (currentSocietyId == null) return;
    
    _adminSubscription = _db.child('block_admins').onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == null || value is! Map) {
        admins.clear();
        isLoading.value = false;
        return;
      }

      final map = Map<dynamic, dynamic>.from(value);
      final list = <BlockAdminModel>[];
      for (final entry in map.entries) {
        if (entry.value is! Map) continue;
        final adminMap = Map<dynamic, dynamic>.from(entry.value as Map);
        if (adminMap['societyId'] == currentSocietyId) {
          list.add(BlockAdminModel.fromMap(entry.key.toString(), adminMap));
        }
      }

      list.sort((a, b) => a.blockName.compareTo(b.blockName));
      admins.assignAll(list);
      isLoading.value = false;
    });
  }

  void prepareCreate() {
    editingAdminId.value = null;
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    passwordController.clear();
    selectedBlockName.value = null;
    isActive.value = true;
  }

  void prepareEdit(BlockAdminModel admin) {
    editingAdminId.value = admin.id;
    nameController.text = admin.name;
    mobileController.text = admin.mobile;
    emailController.text = admin.email;
    passwordController.text = admin.password;
    selectedBlockName.value = admin.blockName;
    isActive.value = admin.isActive;
  }

  Future<bool> saveBlockAdmin() async {
    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final blockName = selectedBlockName.value;

    if (name.isEmpty ||
        mobile.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        blockName == null) {
      Get.snackbar('Error', 'Please fill all details'.tr); // Add proper trans if keys exist
      return false;
    }
    if (password.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters'.tr);
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Enter valid email'.tr);
      return false;
    }

    if (currentSocietyId == null) return false;

    isSaving.value = true;
    try {
      final existingId = editingAdminId.value;
      final ref = existingId == null
          ? _db.child('block_admins').push()
          : _db.child('block_admins/$existingId');
      final adminId = existingId ?? ref.key;
      if (adminId == null) return false;

      String? userUid;
      if (existingId == null) {
        try {
          final credential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);
          userUid = credential.user?.uid;
          if (userUid == null) {
            Get.snackbar('Error', 'Unable to create login user');
            return false;
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            Get.snackbar('Error', 'This email is already used');
          } else {
            Get.snackbar('Error', 'Unable to create login account');
          }
          return false;
        }
      } else {
        userUid = admins.firstWhereOrNull((a) => a.id == existingId)?.userUid;
      }

      String? previousBlockName;
      if (existingId != null) {
        final previous = admins.firstWhereOrNull((a) => a.id == existingId);
        previousBlockName = previous?.blockName;
      }

      final payload = {
        'id': adminId,
        'userUid': userUid,
        'name': name,
        'mobile': mobile,
        'email': email,
        'password': password,
        'societyId': currentSocietyId,
        'blockName': blockName,
        'isActive': isActive.value,
        'createdAt': existingId == null
            ? DateTime.now().toIso8601String()
            : admins.firstWhereOrNull((a) => a.id == existingId)?.createdAt,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await ref.set(payload);
      if (userUid != null) {
        await _db.child('users/$userUid').set({
          'email': email,
          'password': password,
          'role': 'block_admin',
          'societyId': currentSocietyId,
          'blockName': blockName,
          'adminId': adminId,
          'isActive': isActive.value,
        });
      }

      await _db
          .child('society_name/$currentSocietyId/blocks/$blockName/admin')
          .set({
        'id': adminId,
        'userUid': userUid,
        'name': name,
        'mobile': mobile,
        'email': email,
        'isActive': isActive.value,
      });

      if (previousBlockName != null && previousBlockName != blockName) {
        final prevAdminSnapshot = await _db
            .child('society_name/$currentSocietyId/blocks/$previousBlockName/admin/id')
            .get();
        if (prevAdminSnapshot.value?.toString() == adminId) {
          await _db
              .child('society_name/$currentSocietyId/blocks/$previousBlockName/admin')
              .remove();
        }
      }

      Get.snackbar('Success', 'Block admin saved');
      return true;
    } catch (_) {
      Get.snackbar('Error', 'Failed to save admin');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleAdminStatus(BlockAdminModel admin, bool value) async {
    try {
      await _db.child('block_admins/${admin.id}/isActive').set(value);
      if ((admin.userUid ?? '').isNotEmpty) {
        await _db.child('users/${admin.userUid}/isActive').set(value);
      }
      await _db
          .child('society_name/${currentSocietyId}/blocks/${admin.blockName}/admin/isActive')
          .set(value);
    } catch (_) {
      Get.snackbar('Error', 'Unable to update status');
    }
  }

  @override
  void onClose() {
    _adminSubscription?.cancel();
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
