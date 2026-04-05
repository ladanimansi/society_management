import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:society_application/localization/localization_service.dart';
import '../theme/color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.titleStyle,
    this.centerTitle = true,
    this.elevation = 0,
    this.showLanguageSwitcher = true,
    this.showLogout = false, // ✅ NEW
  });

  final String? title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? titleStyle;
  final bool centerTitle;
  final double elevation;
  final bool showLanguageSwitcher;
  final bool showLogout; // ✅ NEW

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? AppColors.primary;
    final effectiveForegroundColor = foregroundColor ?? Colors.white;

    final defaultActions = <Widget>[
      /// 🌐 Language Switcher
      if (showLanguageSwitcher)
        PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          tooltip: 'COMMON-LANGUAGE'.tr,
          onSelected: (value) => LocalizationService.changeLanguage(value),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'en', child: Text('COMMON-ENGLISH'.tr)),
            PopupMenuItem(value: 'hi', child: Text('COMMON-HINDI'.tr)),
            PopupMenuItem(value: 'gu', child: Text('COMMON-GUJARATI'.tr)),
          ],
        ),

      /// 🔴 Logout Button (ONLY when enabled)
      if (showLogout)
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'COMMON-LOGOUT'.tr,
          onPressed: () => _confirmLogout(context),
        ),
    ];

    return AppBar(
      title: title != null
          ? Text(
              title!.tr,
              style:
                  titleStyle ??
                  theme.textTheme.titleLarge?.copyWith(
                    color: effectiveForegroundColor,
                    fontWeight: FontWeight.w600,
                  ),
            )
          : null,
      centerTitle: centerTitle,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: elevation,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: onBackPressed ?? () => Get.back(),
              tooltip: 'COMMON-BACK'.tr,
            )
          : null,
      actions: [...defaultActions, ...(actions ?? [])],
    );
  }

  /// ✅ Logout Confirmation Dialog
  void _confirmLogout(BuildContext context) {
    Get.defaultDialog(
      title: 'COMMON-LOGOUT'.tr,
      middleText: 'COMMON-LOGOUT-CONFIRM'.tr,
      textConfirm: 'COMMON-YES'.tr,
      textCancel: 'COMMON-NO'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // close dialog
        _logout();
      },
    );
  }

  /// ✅ Logout Logic (Firebase + Local साफ)
  void _logout() async {
    try {
      /// Firebase Logout
      await FirebaseAuth.instance.signOut();

      /// Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      /// Navigate to Login Screen
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout failed',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
