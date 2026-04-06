import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:society_application/routes/app_routes.dart';

import '../../common_widgets/custom_app_bar.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/custom_text_field.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'COMMON-LOGIN', showBackButton: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ✅ Email Field
                CustomTextField(
                  controller: controller.emailController,
                  labelText: 'COMMON-EMAIL'.tr,
                  hintText: 'AUTH-ENTER_EMAIL'.tr,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: controller.validateEmail,
                ),

                const SizedBox(height: 16),

                // ✅ Password Field with Obx (for auth error)
                CustomTextField(
                  controller: controller.passwordController,
                  labelText: 'COMMON-PASSWORD'.tr,
                  hintText: 'AUTH-ENTER_PASSWORD'.tr,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: controller.validatePassword,

                  // 🔥 Clear backend error on typing
                  onChanged: (value) {
                    controller.clearAuthError();
                  },
                ),

                const SizedBox(height: 24),

                // ✅ Login Button
                CustomButton(
                  text: 'COMMON-LOGIN'.tr,
                  onPressed: () => controller.login(),
                ),

                const SizedBox(height: 24),

                // ✅ Register Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'AUTH-NO_ACCOUNT'.tr,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.registration),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('COMMON-REGISTER'.tr),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
