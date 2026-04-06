import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common_widgets/custom_app_bar.dart';
import '../../../routes/app_routes.dart';
import 'resident_home_controller.dart';

class ResidentHomeView extends GetView<ResidentHomeController> {
  const ResidentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Home', showBackButton: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'hello mansi',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
