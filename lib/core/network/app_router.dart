import 'package:fuel_tracker/features/about/pages/about_page.dart';
import 'package:fuel_tracker/features/auth/pages/forgot_password.dart';
import 'package:fuel_tracker/features/auth/pages/reset_password.dart';
import 'package:fuel_tracker/features/auth/pages/sign_in.dart';
import 'package:fuel_tracker/features/auth/pages/sign_up.dart';
import 'package:fuel_tracker/features/backup/pages/backup_page.dart';
import 'package:fuel_tracker/features/fuel/binding/add_binding.dart';
import 'package:fuel_tracker/features/fuel/pages/fuel_page.dart';
import 'package:fuel_tracker/features/main/main_screen.dart';
import 'package:fuel_tracker/features/notification/pages/notification_page.dart';
import 'package:fuel_tracker/features/settings/pages/settings_page.dart';
import 'package:fuel_tracker/features/splash/pages/splash_page.dart';
import 'package:fuel_tracker/features/vehicles/pages/add_vehicle_page.dart';
import 'package:fuel_tracker/features/vehicles/pages/vehicle_page.dart';
import 'package:get/get.dart';

import '../../features/fuel/pages/home_page.dart';

abstract class  AppPages {
  static final pages = <GetPage>[
    GetPage(
      page: () => SplashPage(),
      name: PagesRoutes.splashRoute,
    ),
    GetPage(
      page: () => MainScreen(),
      name: PagesRoutes.mainRoute,
    ),
    GetPage(
      page: () => HomePage(),
      name: PagesRoutes.homeRoute,
    ),
    GetPage(
      page: () => SettingPage(),
      name: PagesRoutes.settingRoute,
    ),
    GetPage(
      page: () => VehiclePage(),
      name: PagesRoutes.vehicleRoute,
    ),
    GetPage(
      page: () => VehicleAddPage(),
      name: PagesRoutes.addVehicleRoute,
    ),
    GetPage(
      page: () => NotifPage(),
      name: PagesRoutes.notifRoute,
    ),
    GetPage(
      page: () => SignInPage(),
      name: PagesRoutes.signInRoute,
    ),
    GetPage(
      page: () => SignUpPage(),
      name: PagesRoutes.signUpRoute,
    ),    
    GetPage(
      page: () => FuelPage(),
      name: PagesRoutes.fuelRoute,
      binding: AddBinding(),
    ),
    GetPage(
      page: () => AboutPage(),
      name: PagesRoutes.aboutRoute,
    ),
    GetPage(
      page: () => BackupPage(),
      name: PagesRoutes.backupRoute,
    ),
    GetPage(
      page: () => ForgotPassword(),
      name: PagesRoutes.passwordRoute,
    ),
    GetPage(
      page: () => ResetPassword(),
      name: PagesRoutes.resetPasswordRoute,
    ),
  ];
}

abstract class PagesRoutes {
  static const mainRoute = '/main';
  static const homeRoute = '/home';
  static const settingRoute = '/setting';
  static const addVehicleRoute = '/add_vehicle';
  static const vehicleRoute = '/vehicle';
  static const notifRoute = '/notif';
  static const backupRoute = '/backup';
  static const splashRoute = '/splash';
  static const signInRoute = '/signIn';
  static const signUpRoute = '/signUp';  
  static const passwordRoute = '/forgot_password';  
  static const resetPasswordRoute = '/reset_password';  
  static const fuelRoute = '/fuel';
  static const aboutRoute = '/about';
}
