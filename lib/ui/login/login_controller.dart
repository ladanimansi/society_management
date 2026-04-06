import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:society_application/constants/app_constants.dart';
import 'package:society_application/routes/app_routes.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final authErrorMessage = ''.obs;

  // ✅ Email Regex
  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // ✅ Email Validation
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ✅ Password Validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (authErrorMessage.value.isNotEmpty) {
      return authErrorMessage.value;
    }

    return null;
  }

  // ✅ Clear error when user types
  void clearAuthError() {
    if (authErrorMessage.value.isNotEmpty) {
      authErrorMessage.value = '';
    }
  }

  Future<void> login() async {
    authErrorMessage.value = '';

    if (formKey.currentState?.validate() != true) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      // ✅ Step 1: Login
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      // ✅ Step 2: Fetch user role from Realtime DB
      final snapshot = await FirebaseDatabase.instance.ref('users/$uid').get();

      if (!snapshot.exists) {
        authErrorMessage.value = 'User data not found.';
        formKey.currentState?.validate();
        return;
      }

      final data = snapshot.value as Map;

      final role = data['role'];
      final isActive = data['isActive'];

      if (role == 'society_admin' && isActive == false) {
        authErrorMessage.value = 'Your account is inactive.';
        formKey.currentState?.validate();
        await FirebaseAuth.instance.signOut();
        return;
      }

      // ✅ Step 3: Redirect based on role
      if (role == 'resident') {
        Get.offAllNamed(AppRoutes.residenthome);
      } else if (role == 'super_admin') {
        Get.offAllNamed(AppRoutes.superadminhome);
      } else if (role == 'society_admin') {
        Get.offAllNamed(AppRoutes.societyadminhome);
      } else {
        authErrorMessage.value = 'Invalid role assigned.';
        formKey.currentState?.validate();
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed. Please try again.';

      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled.';
      }

      authErrorMessage.value = message;
      formKey.currentState?.validate();
    } catch (e) {
      authErrorMessage.value = 'Something went wrong.';
      formKey.currentState?.validate();
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
