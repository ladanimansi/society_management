import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:society_application/constants/app_constants.dart';
import '../../common_widgets/custom_app_bar.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/custom_text_field.dart';
import 'registration_controller.dart';

class RegistrationView extends GetView<RegistrationController> {
  const RegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'COMMON-REGISTER', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                controller: controller.emailController,
                labelText: 'COMMON-EMAIL'.tr,
                hintText: 'AUTH-ENTER_EMAIL'.tr,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'AUTH-EMAIL_REQUIRED'.tr;
                  }
                  const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                  if (!RegExp(emailRegex).hasMatch(value.trim())) {
                    return 'AUTH-VALID_EMAIL'.tr;
                  }
                  return null;
                },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                controller: controller.passwordController,
                labelText: 'COMMON-PASSWORD'.tr,
                hintText: 'AUTH-ENTER_PASSWORD_MIN'.tr,
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'AUTH-PASSWORD_REQUIRED'.tr;
                  }
                  if (value.length < AppConstants.minPasswordLength) {
                    return 'Password must be at least ${AppConstants.minPasswordLength} characters';
                  }
                  return null;
                },
                ),
                const SizedBox(height: 24),
                Obx(
                () => CustomButton(
                  text: 'COMMON-REGISTER'.tr,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.register(),
                ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'AUTH-HAVE_ACCOUNT'.tr,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('COMMON-LOGIN'.tr),
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
