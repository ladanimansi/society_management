import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common_widgets/custom_button.dart';
import '../../theme/color.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.home_work_rounded,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'APP-TITLE'.tr,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              CustomButton(
                text: 'SPLASH-START'.tr,
                onPressed: controller.onStartPressed,
                backgroundColor: Colors.white,
                textColor: AppColors.primary,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
