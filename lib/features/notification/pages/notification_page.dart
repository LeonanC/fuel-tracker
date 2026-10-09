import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/features/notification/controllers/notification_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class NotifPage extends GetView<NotifController> {
  const NotifPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverToBoxAdapter(
              child: Obx(
                () => Material(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    0.5,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  clipBehavior: Clip.antiAlias,
                  child: SwitchListTile(
                    secondary: Icon(
                      RemixIcons.notification_line,
                      color: theme.colorScheme.primary,
                      size: 22.r,
                    ),
                    title: Text(
                      'notif_allow_all_title'.tr,
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    subtitle: Text(
                      'notif_allow_all_subtitle'.tr,
                      style: GoogleFonts.lexend(fontSize: 12.sp),
                    ),
                    value: controller.allowAllNotifications.value,
                    onChanged: (val) => controller.toggleAll(val),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 24.h,
              bottom: 8.h,
            ),
            sliver: SliverToBoxAdapter(
              child: _buildSectionHeader(theme, 'notif_vehicle_title'.tr),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Obx(
                  () => _buildNotificationTile(
                    theme: theme,
                    icon: RemixIcons.gas_station_line,
                    title: 'notif_refuel_title'.tr,
                    subtitle: 'notif_refuel_subtitle'.tr,
                    value: controller.refuelReminders.value,
                    onChanged: controller.allowAllNotifications.value
                        ? (val) => controller.toggleRefuel(val)
                        : null,
                  ),
                ),
                Obx(
                  () => _buildNotificationTile(
                    theme: theme,
                    icon: RemixIcons.tools_line,
                    title: 'notif_maintenance_title'.tr,
                    subtitle: 'notif_maintenance_subtitle'.tr,
                    value: controller.maintenanceReminders.value,
                    onChanged: controller.allowAllNotifications.value
                        ? (val) => controller.toggleMaintenance(val)
                        : null,
                  ),
                ),
                Obx(
                  () => _buildNotificationTile(
                    theme: theme,
                    icon: RemixIcons.drop_line,
                    title: 'notif_oil_title'.tr,
                    subtitle: 'notif_oil_subtitle'.tr,
                    value: controller.oilChangeAlerts.value,
                    onChanged: controller.allowAllNotifications.value
                        ? (val) => controller.toggleOilChange(val)
                        : null,
                  ),
                ),
                Obx(
                  () => _buildNotificationTile(
                    theme: theme,
                    icon: RemixIcons.gas_station_line,
                    title: 'notif_station_title'.tr,
                    subtitle: 'notif_station_subtitle'.tr,
                    value: controller.newStation.value,
                    onChanged: controller.allowAllNotifications.value
                        ? (val) => controller.toggleNewStation(val)
                        : null,
                  ),
                ),
                Obx(
                  () => _buildNotificationTile(
                    theme: theme,
                    icon: RemixIcons.car_line,
                    title: 'notif_vehicle_title'.tr,
                    subtitle: 'notif_vehicle_subtitle'.tr,
                    value: controller.newVehicle.value,
                    onChanged: controller.allowAllNotifications.value
                        ? (val) => controller.toggleNewVehicle(val)
                        : null,
                  ),
                ),
              ]),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 24.h,
              bottom: 8.h,
            ),
            sliver: SliverToBoxAdapter(child: Divider(height: 32.h)),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 24.h,
              bottom: 8.h,
            ),
            sliver: SliverToBoxAdapter(
              child: _buildSectionHeader(theme, 'notif_section_others'.tr),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Obx(
                  () => _buildNotificationTile(
                    theme: theme,
                    icon: RemixIcons.lightbulb_line,
                    title: 'notif_tips_title'.tr,
                    subtitle: 'notif_tips_subtitle'.tr,
                    value: controller.promotionsAndTips.value,
                    onChanged: controller.allowAllNotifications.value
                    ? (val) => controller.togglePromotions(val)
                    : null,
                  ),
                ),
              ]),
            ),
          ),
          SliverPadding(padding: EdgeInsets.only(bottom: 32.h)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 60.h,
      pinned: true,
      floating: true,
      elevation: 0,
      backgroundColor:
          theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(start: 50.w, bottom: 16.h),
        title: Text(
          'notif_title'.tr,
          style: GoogleFonts.lexend(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: GoogleFonts.lexend(
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildNotificationTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: theme.colorScheme.onSurfaceVariant,
        size: 22.r,
      ),
      title: Text(title, style: GoogleFonts.lexend(fontSize: 15.sp)),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.lexend(
          fontSize: 12.sp,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
