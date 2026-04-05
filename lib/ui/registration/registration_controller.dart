import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:society_application/constants/app_constants.dart';
import 'package:society_application/routes/app_routes.dart';

class RegistrationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  Future<void> register() async {
    if (formKey.currentState?.validate() != true) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    isLoading.value = true;
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final uid = credential.user?.uid;
      if (uid == null) {
        return;
      }

      final databaseRef = FirebaseDatabase.instance
          .ref(AppConstants.usersPath)
          .child(uid);
      await databaseRef.set({
        'email': email,
        'password': password,
        'role': AppConstants.defaultRole,
      });

      Get.offAllNamed(AppRoutes.login);
    } on FirebaseAuthException catch (_) {
      // Auth error - no snackbar
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
