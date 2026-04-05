import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:society_application/ui/super_admin/society_admin/society_admin_controller.dart';

class SocietyAdminProfileController extends GetxController {
  final _db = FirebaseDatabase.instance.ref();
  StreamSubscription<DatabaseEvent>? _adminSubscription;

  final admins = <SocietyAdminModel>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isActive = true.obs;
  final editingAdminId = RxnString();

  final mySocietyId = RxnString();
  final mySocietyName = RxnString();

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
        isLoading.value = false;
        return;
      }

      final userSnapshot = await _db.child('users/$uid').get();
      if (!userSnapshot.exists || userSnapshot.value is! Map) {
        isLoading.value = false;
        return;
      }

      final userData = Map<dynamic, dynamic>.from(userSnapshot.value as Map);
      mySocietyId.value = userData['societyId']?.toString();
      mySocietyName.value = userData['societyName']?.toString();

      if (mySocietyId.value == null || mySocietyId.value!.isEmpty) {
        isLoading.value = false;
        return;
      }

      _listenMySocietyAdmins();
    } catch (_) {
      isLoading.value = false;
    }
  }

  void _listenMySocietyAdmins() {
    _adminSubscription = _db.child('society_admins').orderByChild('societyId').equalTo(mySocietyId.value).onValue.listen((event) {
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

      list.sort((a, b) => a.name.compareTo(b.name));
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
    isActive.value = true;
  }

  void prepareEdit(SocietyAdminModel admin) {
    editingAdminId.value = admin.id;
    nameController.text = admin.name;
    mobileController.text = admin.mobile;
    emailController.text = admin.email;
    passwordController.text = admin.password;
    isActive.value = admin.isActive;
  }

  Future<bool> saveSocietyAdmin() async {
    if (mySocietyId.value == null) {
      Get.snackbar('Error', 'Society ID not available');
      return false;
    }

    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || mobile.isEmpty || email.isEmpty || password.isEmpty) {
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

    isSaving.value = true;
    FirebaseApp? secondaryApp;
    try {
      final existingId = editingAdminId.value;
      final ref = existingId == null
          ? _db.child('society_admins').push()
          : _db.child('society_admins/$existingId');
      final adminId = existingId ?? ref.key;
      if (adminId == null) return false;

      String? userUid;
      if (existingId == null) {
        // Create user using a secondary Firebase app so the active user is not logged out
        try {
          secondaryApp = await Firebase.initializeApp(
            name: 'SecondaryApp',
            options: Firebase.app().options,
          );
          final credential = await FirebaseAuth.instanceFor(app: secondaryApp)
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
        } finally {
          if (secondaryApp != null) {
            await secondaryApp.delete();
          }
        }
      } else {
        userUid = admins.firstWhereOrNull((a) => a.id == existingId)?.userUid;
      }

      final payload = {
        'id': adminId,
        'userUid': userUid,
        'name': name,
        'mobile': mobile,
        'email': email,
        'password': password,
        'societyId': mySocietyId.value,
        'societyName': mySocietyName.value ?? 'Unnamed Society',
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
          'societyId': mySocietyId.value,
          'societyName': mySocietyName.value ?? 'Unnamed Society',
          'adminId': adminId,
          'isActive': isActive.value,
        });
      }
      
      await _db.child('society_name/${mySocietyId.value}/admin').set({
        'id': adminId,
        'userUid': userUid,
        'name': name,
        'mobile': mobile,
        'email': email,
        'isActive': isActive.value,
      });

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
      // Assuming we modify the root admin node for the society if matched
      final snapshot = await _db.child('society_name/${admin.societyId}/admin/id').get();
      if (snapshot.value?.toString() == admin.id) {
        await _db.child('society_name/${admin.societyId}/admin/isActive').set(value);
      }
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
