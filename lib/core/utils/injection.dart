import 'package:fuel_tracker/features/about/controllers/about_controller.dart';
import 'package:fuel_tracker/features/auth/controllers/auth_controller.dart';
import 'package:fuel_tracker/features/backup/controllers/backup_controller.dart';
import 'package:fuel_tracker/features/fuel/controllers/home_controller.dart';
import 'package:fuel_tracker/features/fuel/services/offline_sync_service.dart';
import 'package:fuel_tracker/features/notification/controllers/notification_controller.dart';
import 'package:fuel_tracker/features/profile/controller/perfil_controller.dart';
import 'package:fuel_tracker/features/settings/controller/settings_controller.dart';
import 'package:fuel_tracker/features/splash/controllers/splash_controller.dart';
import 'package:fuel_tracker/features/vehicles/controllers/add_vehicle_controller.dart';
import 'package:fuel_tracker/features/vehicles/controllers/vehicle_controller.dart';
import 'package:get/get.dart';

void setupServiceLocator() {
  Get.put<OfflineSyncService>(OfflineSyncService(), permanent: true);
  Get.put<AboutController>(AboutController(), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<HomeController>(HomeController(), permanent: true);
  Get.put<PerfilController>(PerfilController(), permanent: true);
  Get.put<VehicleController>(VehicleController(), permanent: true);
  Get.put<AddVehicleController>(AddVehicleController(), permanent: true);
  Get.put<NotifController>(NotifController(), permanent: true);
  Get.put<BackupController>(BackupController(), permanent: true);
  Get.put<SettingsController>(SettingsController(), permanent: true);
  Get.put<SplashController>(SplashController(), permanent: true);
}
