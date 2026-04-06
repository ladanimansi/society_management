import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SocietyAdminModel {
  final String id;
  final String? userUid;
  final String name;
  final String mobile;
  final String email;
  final String password;
  final String societyId;
  final String societyName;
  final bool isActive;
  final String? createdAt;

  const SocietyAdminModel({
    required this.id,
    this.userUid,
    required this.name,
    required this.mobile,
    required this.email,
    required this.password,
    required this.societyId,
    required this.societyName,
    required this.isActive,
    this.createdAt,
  });

  factory SocietyAdminModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return SocietyAdminModel(
      id: id,
      userUid: map['userUid']?.toString(),
      name: (map['name'] ?? '').toString(),
      mobile: (map['mobile'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      password: (map['password'] ?? '').toString(),
      societyId: (map['societyId'] ?? '').toString(),
      societyName: (map['societyName'] ?? '').toString(),
      isActive: map['isActive'] == true,
      createdAt: map['createdAt']?.toString(),
    );
  }
}

class SocietyAdminController extends GetxController {
  final _db = FirebaseDatabase.instance.ref();
  StreamSubscription<DatabaseEvent>? _adminSubscription;

  final admins = <SocietyAdminModel>[].obs;
  final societies = <Map<String, String>>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final selectedSocietyId = RxnString();
  final isActive = true.obs;
  final editingAdminId = RxnString();

  @override
  void onInit() {
    super.onInit();
    _listenSocietyAdmins();
    loadSocieties();
  }

  Future<void> loadSocieties() async {
    try {
      final snapshot = await _db.child('society_name').get();
      if (!snapshot.exists || snapshot.value is! Map) {
        societies.clear();
        return;
      }

      final map = Map<dynamic, dynamic>.from(snapshot.value as Map);
      final list = map.entries.map((entry) {
        final data = entry.value is Map
            ? Map<dynamic, dynamic>.from(entry.value as Map)
            : <dynamic, dynamic>{};
        return {
          'id': entry.key.toString(),
          'name': (data['name'] ?? 'Unnamed Society').toString(),
        };
      }).toList();

      list.sort((a, b) => a['name']!.compareTo(b['name']!));
      societies.assignAll(list);
    } catch (_) {}
  }

  void _listenSocietyAdmins() {
    _adminSubscription = _db.child('society_admins').onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == null || value is! Map) {
        admins.clear();
        isLoading.value = false;
        return;
      }

      final map = Map<dynamic, dynamic>.from(value);
      final list = <SocietyAdminModel>[];
      for (final entry in map.entries) {
        if (entry.value is! Map) continue;
        list.add(
          SocietyAdminModel.fromMap(
            entry.key.toString(),
            Map<dynamic, dynamic>.from(entry.value as Map),
          ),
        );
      }

      list.sort((a, b) => a.societyName.compareTo(b.societyName));
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
    selectedSocietyId.value = null;
    isActive.value = true;
  }

  void prepareEdit(SocietyAdminModel admin) {
    editingAdminId.value = admin.id;
    nameController.text = admin.name;
    mobileController.text = admin.mobile;
    emailController.text = admin.email;
    passwordController.text = admin.password;
    selectedSocietyId.value = admin.societyId;
    isActive.value = admin.isActive;
  }

  Future<bool> saveSocietyAdmin() async {
    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final societyId = selectedSocietyId.value;

    if (name.isEmpty ||
        mobile.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        societyId == null) {
      Get.snackbar('Error', 'Please fill all details');
      return false;
    }
    if (password.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Enter valid email');
      return false;
    }

    final society = societies.firstWhereOrNull((e) => e['id'] == societyId);
    if (society == null) {
      Get.snackbar('Error', 'Please select valid society');
      return false;
    }

    isSaving.value = true;
    try {
      final existingId = editingAdminId.value;
      final ref = existingId == null
          ? _db.child('society_admins').push()
          : _db.child('society_admins/$existingId');
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

      String? previousSocietyId;
      if (existingId != null) {
        final previous = admins.firstWhereOrNull((a) => a.id == existingId);
        previousSocietyId = previous?.societyId;
      }

      final payload = {
        'id': adminId,
        'userUid': userUid,
        'name': name,
        'mobile': mobile,
        'email': email,
        'password': password,
        'societyId': societyId,
        'societyName': society['name'],
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
          'role': 'society_admin',
          'societyId': societyId,
          'societyName': society['name'],
          'adminId': adminId,
          'isActive': isActive.value,
        });
      }
      await _db.child('society_name/$societyId/admin').set({
        'id': adminId,
        'userUid': userUid,
        'name': name,
        'mobile': mobile,
        'email': email,
        'isActive': isActive.value,
      });

      if (previousSocietyId != null && previousSocietyId != societyId) {
        final prevAdminSnapshot = await _db
            .child('society_name/$previousSocietyId/admin/id')
            .get();
        if (prevAdminSnapshot.value?.toString() == adminId) {
          await _db.child('society_name/$previousSocietyId/admin').remove();
        }
      }

      Get.snackbar('Success', 'Society admin saved');
      return true;
    } catch (_) {
      Get.snackbar('Error', 'Failed to save admin');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleAdminStatus(SocietyAdminModel admin, bool value) async {
    try {
      await _db.child('society_admins/${admin.id}/isActive').set(value);
      if ((admin.userUid ?? '').isNotEmpty) {
        await _db.child('users/${admin.userUid}/isActive').set(value);
      }
      await _db
          .child('society_name/${admin.societyId}/admin/isActive')
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
