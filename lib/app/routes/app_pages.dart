import 'package:get/get.dart';

import '../modules/activity_log/bindings/activity_log_binding.dart';
import '../modules/activity_log/views/activity_log_view.dart';
import '../modules/business_info/bindings/business_info_binding.dart';
import '../modules/business_info/views/business_info_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/inventory/bindings/inventory_binding.dart';
import '../modules/inventory/views/inventory_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/market/bindings/market_binding.dart';
import '../modules/market/views/market_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/otp/bindings/otp_binding.dart';
import '../modules/otp/views/otp_view.dart';
import '../modules/otp_verification/bindings/otp_verification_binding.dart';
import '../modules/otp_verification/views/otp_verification_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/scan/bindings/scan_binding.dart';
import '../modules/scan/views/scan_view.dart';
import '../modules/security/bindings/security_binding.dart';
import '../modules/security/views/security_view.dart';
import '../modules/splash/controllers/splash_controller.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.SCAN,
      page: () => const ScanView(),
      binding: ScanBinding(),
    ),
    GetPage(
      name: Routes.INVENTORY,
      page: () => const InventoryView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: Routes.MARKET, // Menggunakan konstanta tunggal
      page: () =>
          const MarketView(), // Mengarah ke tampilan Market yang Anda mau
      binding: MarketBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.OTP,
      page: () => const OtpView(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: Routes.OTP_VERIFICATION,
      page: () => const OtpVerificationView(),
      binding: OtpVerificationBinding(),
    ),
    GetPage(
      name: Routes.NOTIFICATION,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: Routes.ACTIVITY_LOG,
      page: () => const ActivityLogView(),
      binding: ActivityLogBinding(),
    ),
    GetPage(
      name: Routes.BUSINESS_INFO,
      page: () => const BusinessInfoView(),
      binding: BusinessInfoBinding(),
    ),
    GetPage(
      name: _Paths.SECURITY,
      page: () => const SecurityView(),
      binding: SecurityBinding(),
    ),
  ];
}
