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
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(theme),
          Obx(() {
            if (controller.isLoading.value) {
              return SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (controller.userVehicles.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(RemixIcons.car_line, size: 64.r, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text(
                        'st_not_vehicle'.tr,
                        style: GoogleFonts.lexend(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final vehicle = controller.userVehicles[index];

                  return Obx(() {
                    final isSelected =
                        authController.currentUser.value?.vehicle == vehicle.id;

                    return Card(
                      elevation: isSelected ? 3 : 1,
                      margin: EdgeInsets.only(bottom: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        side: isSelected
                            ? BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              )
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            RemixIcons.car_fill,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          vehicle.name ?? "st_unnamed_vehicle".tr,
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        subtitle: Text(
                          isSelected
                              ? 'st_active_vehicle'.tr
                              : 'st_tap_select_vehicle'.tr,
                          style: GoogleFonts.lexend(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.grey,
                            fontSize: 12.sp,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              Icon(
                                RemixIcons.checkbox_circle_fill,
                                color: theme.colorScheme.primary,
                              ),
                            IconButton(
                              icon: Icon(
                                RemixIcons.delete_bin_line,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  _showDeleteDialog(context, vehicle.id!),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (vehicle.id != null) {
                            controller.setSelectedVehicle(vehicle.id!);
                          }
                        },
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
        icon: Icon(RemixIcons.add_line, color: Colors.white),
        label: Text(
          'st_new_vehicle'.tr,
          style: GoogleFonts.lexend(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
      backgroundColor:
          theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
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
    Get.defaultDialog(
      title: 'st_dialog_vehicle'.tr,
      middleText: 'st_dialog_vehicle_sub'.tr,
      textConfirm: 'st_text_confirm'.tr,
      textCancel: 'st_text_cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
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
