import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/core/network/app_router.dart';
import 'package:fuel_tracker/features/settings/controller/settings_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class SettingPage extends GetView<SettingsController> {
  SettingPage({super.key});

  final List<Locale> supportedLocales = const [
    Locale('pt', 'BR'),
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
    Locale('de', 'DE'),
    Locale('it', 'IT'),
    Locale('ja', 'JP'),
    Locale('zh', 'CN'),
    Locale('ko', 'KR'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 60.h,
            pinned: true,
            elevation: 0,
            stretch: true,
            backgroundColor:
                theme.appBarTheme.backgroundColor ??
                theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsetsDirectional.only(
                start: 50.w,
                bottom: 16.h,
              ),
              centerTitle: false,
              title: Text(
                'st_title'.tr,
                style: GoogleFonts.lexend(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _buildSectionTitle("pf_section_general".tr),
                  SizedBox(height: 8.h),
                  _buildSettingsTile(
                    theme: theme,
                    icon: RemixIcons.car_line,
                    title: "st_my_vehicles".tr,
                    subtitle: "st_my_vehicles_sub".tr,
                    onTap: () => Get.toNamed(PagesRoutes.vehicleRoute),
                  ),
                  _buildSettingsTile(
                    theme: theme,
                    icon: RemixIcons.notification_line,
                    title: "st_notifications".tr,
                    subtitle: "st_notifications_sub".tr,
                    onTap: () => Get.toNamed(PagesRoutes.notifRoute),
                  ),
                  _buildSectionTitle("st_section_preferences".tr),
                  SizedBox(height: 8.h),
                  _buildSettingsTile(
                    theme: theme,
                    icon: RemixIcons.car_line,
                    title: "st_app_theme".tr,
                    subtitle: "st_app_theme_sub".tr,
                    onTap: () {
                      Get.changeThemeMode(
                        Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                      );
                    },
                  ),
                  Obx(
                    () => _buildSettingsTile(
                      theme: theme,
                      icon: RemixIcons.global_line,
                      title: "st_language".tr,
                      subtitle: controller.getLanguageName(
                        controller.selectedLocale.value ??
                            Get.locale ??
                            const Locale('pt', 'BR'),
                      ),
                      onTap: () => _showLanguageDialog(theme),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildSectionTitle("st_section_about".tr),
                  SizedBox(height: 8.h),
                  Obx(
                    () => _buildSettingsTile(
                      theme: theme,
                      icon: RemixIcons.information_line,
                      title: "st_app_version".tr,
                      subtitle: controller.appVersion.value.isEmpty
                      ? 'st_loading'.tr
                      : controller.appVersion.value,
                      onTap: () => _showInformationDialog(theme),
                    ),
                  ),
                  _buildSettingsTile(
                    theme: theme,
                    icon: RemixIcons.download_cloud_line,
                    icon2: RemixIcons.upload_cloud_line,
                    title: 'st_backups'.tr,
                    subtitle: 'st_backups_sub'.tr,
                    onTap: () => Get.toNamed(PagesRoutes.backupRoute),
                  ),
                  _buildSettingsTile(
                    theme: theme,
                    icon: RemixIcons.shield_check_line,
                    title: 'st_terms_privacy'.tr,
                    onTap: (){},
                  ),
                  SizedBox(height: 28.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lexend(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildSettingsTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    String? subtitle,
    IconData? icon2,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.lexend(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: Icon(RemixIcons.arrow_right_s_line, color: Colors.grey[400]),
      ),
    );
  }

  void _showLanguageDialog(ThemeData theme) {
    Get.dialog(
      AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'st_select_language'.tr,
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: supportedLocales.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final locale = supportedLocales[index];
              final isSelected =
                  controller.selectedLocale.value?.languageCode ==
                  locale.languageCode;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  controller.getLanguageName(locale),
                  style: GoogleFonts.lexend(
                    fontSize: 14.sp,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        RemixIcons.check_line,
                        color: theme.colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  controller.changeLanguage(locale);
                  Get.back();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showInformationDialog(ThemeData theme){
    Get.defaultDialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      title: "ab_title".tr,
      titleStyle: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold),
      content: Column(
        children: [
          Text(
            'st_about_desc'.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(color: Colors.grey[400], fontSize: 12.sp),
          ),
          Text(
            'st_current_version'.trParams({
              'version': controller.appVersion.value,
            }),
            style: GoogleFonts.lexend(color: Colors.white70, fontSize: 11.sp),
          ),
        ],
      ),
      textConfirm: 'st_ok'.tr,
      confirmTextColor: Colors.white,
      buttonColor: theme.colorScheme.primary,
      onConfirm: () => Get.back(),
    );
  }
}
