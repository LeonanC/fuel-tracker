import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/features/auth/controllers/auth_controller.dart';
import 'package:fuel_tracker/features/notification/controllers/notification_controller.dart';
import 'package:fuel_tracker/features/vehicles/controllers/vehicle_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class VehiclePage extends GetView<VehicleController> {
  VehiclePage({super.key});

  final authController = Get.find<AuthController>();
  final notifController = Get.find<NotifController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(theme),
          Obx(() {
            if (controller.isLoading.value) {
              return SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                ),
              );
            }
            if (controller.userVehicles.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          RemixIcons.car_line,
                          size: 48.r,
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'st_not_vehicle'.tr,
                        style: GoogleFonts.lexend(
                          fontSize: 14.sp,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final vehicle = controller.userVehicles[index];

                  return Obx(() {
                    final isSelected =
                        authController.currentUser.value?.vehicle == vehicle.id;

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      margin: EdgeInsets.only(bottom: 14.h),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface.withOpacity(0.06),
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? colorScheme.primary.withOpacity(0.08)
                                : Colors.black.withOpacity(0.04),
                            blurRadius: 15.r,
                            offset: Offset(0, 5.h),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20.r),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20.r),
                          onTap: () {
                            if (vehicle.id != null) {
                              controller.setSelectedVehicle(vehicle.id!);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16.r),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Icon(
                                    RemixIcons.car_fill,
                                    size: 22.sp,
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.primary,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicle.name ?? "st_unnamed_vehicle".tr,
                                        style: GoogleFonts.lexend(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.sp,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          if (isSelected) ...[
                                            Icon(
                                              RemixIcons.checkbox_circle_fill,
                                              size: 14.sp,
                                              color: colorScheme.primary,
                                            ),
                                            SizedBox(width: 4.w),
                                          ],
                                          Text(
                                            isSelected
                                                ? 'st_active_vehicle'.tr
                                                : 'st_tap_select_vehicle'.tr,
                                            style: GoogleFonts.lexend(
                                              color: isSelected
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurface
                                                        .withOpacity(0.5),
                                              fontSize: 11.sp,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(RemixIcons.delete_bin_line, size: 20.sp, color: colorScheme.error.withOpacity(0.8)),
                                      onPressed: () => _showDeleteDialog(context, vehicle.id!),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                }, childCount: controller.userVehicles.length),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.navigateToAdd(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        icon: Icon(RemixIcons.add_line, size: 20.sp),
        label: Text(
          'st_new_vehicle'.tr,
          style: GoogleFonts.lexend(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 60.h,
      pinned: true,
      floating: true,
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(start: 50.w, bottom: 16.h),
        title: Text(
          'st_my_vehicles'.tr,
          style: GoogleFonts.lexend(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String vehicleId) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Get.defaultDialog(
      title: 'st_dialog_vehicle'.tr,
      titleStyle: GoogleFonts.lexend(
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
        color: colorScheme.onSurface,
      ),
      middleText: 'st_dialog_vehicle_sub'.tr,
      middleTextStyle: GoogleFonts.lexend(
        fontSize: 13.sp,
        color: colorScheme.onSurface.withOpacity(0.7),
      ),
      backgroundColor: colorScheme.surface,
      textConfirm: 'st_text_confirm'.tr,
      textCancel: 'st_text_cancel'.tr,
      confirmTextColor: colorScheme.onError,
      buttonColor: colorScheme.error,
      onConfirm: () async {
        Get.back();
        controller.deleteVehicle(vehicleId);

        await notifController.showNotification(
          id: 105,
          title: 'notif_vehicle_title_deleted'.tr,
          body: 'notif_vehicle_body_deleted'.tr,
        );
      },
    );
  }
}
