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
        child: Obx(
          () => Stepper(
            type: StepperType.vertical,
            currentStep: controller.currentStep.value,
            onStepCancel: controller.previousStep,
            onStepContinue: controller.currentStep.value == 2 
                ? controller.register 
                : controller.nextStep,
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Row(
                  children: [
                    if (controller.currentStep.value > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: CustomButton(
                        text: controller.currentStep.value == 2 ? 'COMMON-REGISTER'.tr : 'Next',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.isLoading.value ? null : details.onStepContinue,
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Select Society'),
                isActive: controller.currentStep.value >= 0,
                state: controller.currentStep.value > 0 ? StepState.complete : StepState.indexed,
                content: Form(
                  key: controller.formKey1,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Society',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        isExpanded: true,
                        value: controller.selectedSocietyId.value,
                        items: controller.societiesList.map((society) {
                          return DropdownMenuItem<String>(
                            value: society['id'] as String,
                            child: Text(society['name'] as String),
                          );
                        }).toList(),
                        onChanged: (val) {
                          final soc = controller.societiesList.firstWhere((s) => s['id'] == val, orElse: () => <String, dynamic>{});
                          controller.onSocietySelected(val, soc['name'] as String?);
                        },
                        validator: (value) => value == null ? 'Please select a society' : null,
                      ),
                    ],
                  ),
                ),
              ),
              Step(
                title: const Text('User Details'),
                isActive: controller.currentStep.value >= 1,
                state: controller.currentStep.value > 1 ? StepState.complete : StepState.indexed,
                content: Form(
                  key: controller.formKey2,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: controller.nameController,
                        labelText: 'Name',
                        hintText: 'Enter your full name',
                        textInputAction: TextInputAction.next,
                        validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: controller.mobileController,
                        labelText: 'Mobile Number',
                        hintText: 'Enter your mobile number',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (value) => value == null || value.trim().isEmpty ? 'Mobile number is required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: controller.emailController,
                        labelText: 'COMMON-EMAIL'.tr,
                        hintText: 'AUTH-ENTER_EMAIL'.tr,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'AUTH-EMAIL_REQUIRED'.tr;
                          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value.trim())) {
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
                          if (value == null || value.isEmpty) return 'AUTH-PASSWORD_REQUIRED'.tr;
                          if (value.length < AppConstants.minPasswordLength) {
                            return 'Password must be at least ${AppConstants.minPasswordLength} characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Step(
                title: const Text('Select Flat'),
                isActive: controller.currentStep.value >= 2,
                content: Form(
                  key: controller.formKey3,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Block',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        isExpanded: true,
                        value: controller.selectedBlock.value,
                        items: controller.availableBlocks.map((block) {
                          return DropdownMenuItem<String>(
                            value: block,
                            child: Text(block),
                          );
                        }).toList(),
                        onChanged: controller.onBlockSelected,
                        validator: (value) => value == null ? 'Please select a block' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Floor',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        isExpanded: true,
                        value: controller.selectedFloor.value,
                        items: controller.availableFloors.map((floor) {
                          final floorLabel = floor.replaceAll('floor_', 'Floor ');
                          return DropdownMenuItem<String>(
                            value: floor,
                            child: Text(floorLabel),
                          );
                        }).toList(),
                        onChanged: controller.onFloorSelected,
                        validator: (value) => value == null ? 'Please select a floor' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Flat',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        isExpanded: true,
                        value: controller.selectedFlat.value,
                        items: controller.availableFlats.map((flat) {
                          return DropdownMenuItem<String>(
                            value: flat,
                            child: Text(flat),
                          );
                        }).toList(),
                        onChanged: (val) => controller.selectedFlat.value = val,
                        validator: (value) => value == null ? 'Please select a flat' : null,
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
            ],
          ),
        ),
      ),
    );
  }
}
