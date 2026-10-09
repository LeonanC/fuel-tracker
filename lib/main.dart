import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/core/network/app_router.dart';
import 'package:fuel_tracker/core/network/supabase_config.dart';
import 'package:fuel_tracker/core/services/app_translations.dart';
import 'package:fuel_tracker/core/theme/app_theme.dart';
import 'package:fuel_tracker/core/utils/injection.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  

  await initializeDateFormatting('pt_BR', null);
  await SupabaseConfig.initialize();

  setupServiceLocator();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Gestão de Abastecimento',
          debugShowCheckedModeBanner: false,
          locale: Get.deviceLocale,
          fallbackLocale: Locale('pt_BR', 'BR'),
          translations: AppTranslations(),
          initialRoute: PagesRoutes.splashRoute,
          getPages: AppPages.pages,
          themeMode: ThemeMode.system,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
        );
      },
    );
  }
}