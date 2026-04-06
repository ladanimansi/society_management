import 'package:get/get.dart';
import 'package:society_application/ui/home/society_admin_dashboard/society_admin_dashboard_binding.dart';
import 'package:society_application/ui/home/society_admin_dashboard/society_admin_dashboard_view.dart';
import 'package:society_application/ui/home/super_admin/super_admin_home_binding.dart';
import 'package:society_application/ui/home/super_admin/super_admin_home_view.dart';
import 'package:society_application/ui/super_admin/create_society_type/building/create_building_binding.dart';
import 'package:society_application/ui/super_admin/create_society_type/building/create_building_view.dart';
import 'package:society_application/ui/super_admin/create_society_type/tenament/create_tenament_binding.dart';
import 'package:society_application/ui/super_admin/create_society_type/tenament/create_tenament_view.dart';
import 'package:society_application/ui/super_admin/society_admin/society_admin_binding.dart';
import 'package:society_application/ui/super_admin/society_admin/society_admin_view.dart';
import '../ui/splash/splash_binding.dart';
import '../ui/splash/splash_view.dart';
import '../ui/home/resident/resident_home_binding.dart';
import '../ui/home/resident/resident_home_view.dart';
import '../ui/login/login_binding.dart';
import '../ui/login/login_view.dart';
import '../ui/registration/registration_binding.dart';
import '../ui/registration/registration_view.dart';
import '../ui/home/block_admin/block_admin_binding.dart';
import '../ui/home/block_admin/block_admin_view.dart';

import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.residenthome,
      page: () => const ResidentHomeView(),
      binding: ResidentHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.superadminhome,
      page: () => const SuperAdminHomeView(),
      binding: SuperAdminHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.societyadminhome,
      page: () => const SocietyAdminDashboardView(),
      binding: SocietyAdminDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.registration,
      page: () => const RegistrationView(),
      binding: RegistrationBinding(),
    ),

    GetPage(
      name: AppRoutes.createBuilding,
      page: () => const CreateBuildingView(),
      binding: CreateBuildingBinding(),
    ),

    GetPage(
      name: AppRoutes.createTenament,
      page: () => const CreateTenamentView(),
      binding: CreateTenamentBinding(),
    ),
    GetPage(
      name: AppRoutes.societyAdmin,
      page: () => const SocietyAdminView(),
      binding: SocietyAdminBinding(),
    ),
    GetPage(
      name: AppRoutes.blockAdmin,
      page: () => const BlockAdminView(),
      binding: BlockAdminBinding(),
    ),
  ];
}
