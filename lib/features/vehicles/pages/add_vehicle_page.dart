import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/features/fuel/services/offline_sync_service.dart';
import 'package:fuel_tracker/features/notification/controllers/notification_controller.dart';
import 'package:fuel_tracker/features/vehicles/controllers/add_vehicle_controller.dart';
import 'package:fuel_tracker/features/widgets/custom_text_field.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class VehicleAddPage extends GetView<AddVehicleController> {
  VehicleAddPage({super.key});

  final notifController = Get.find<NotifController>();
  final syncService = Get.find<OfflineSyncService>();

  void _handleSaveAndNotify() async {
    await controller.submit();
    if(notifController.refuelReminders.value){
      notifController.showNotification(
        id: 101,
        title: 'notif_vehicle_title'.tr,
        body: syncService.isOnline.value
        ? 'notif_vehicle_body_online'.tr
        : 'notif_vehicle_body_offline'.tr,
      );
    }

    if(notifController.oilChangeAlerts.value){
      final kmStr = controller.initialOdometerController.text;
      if(kmStr.isNotEmpty){
        final double? km = double.tryParse(kmStr);
        if(km != null && km > 10000){
          notifController.showNotification(
            id: 103,
            title: 'notif_vehicle_title_oil'.tr,
            body: 'notif_vehicle_body_oil'.tr,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: Obx(() {
        final isFull =
            syncService.pendingQueue.length >= syncService.maxQueueSize;
        final isOnline = syncService.isOnline.value;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.w),
            child: ElevatedButton.icon(
              onPressed: (controller.isLoading.value || (!isOnline && isFull))
                  ? null
                  : _handleSaveAndNotify,
              style: ElevatedButton.styleFrom(
                backgroundColor: !isOnline
                    ? Colors.orange.shade800
                    : theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.secondary,
                minimumSize: Size.fromHeight(52.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 2,
              ),
              icon: controller.isLoading.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      !isOnline
                          ? RemixIcons.cloud_off_line
                          : RemixIcons.check_line,
                      color: theme.colorScheme.secondary,
                    ),
              label: Text(
                !isOnline
                    ? 'hp_btn_save_offline'.trParams({
                        'current': '${syncService.pendingQueue.length}',
                        'max': '${syncService.maxQueueSize}',
                      })
                    : controller.editingEntry != null
                    ? "av_save_btn".tr
                    : "av_register_btn".tr,
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        );
      }),
      body: Form(
        key: controller.formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(controller, theme),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("av_information".tr, theme),
                    _buildCardContainer(
                      child: _buildInputField(controller, theme),
                    ),                    
                    SizedBox(height: 24.h),
                    _buildConnectionBanner(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(AddVehicleController c, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 60.h,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: theme.appBarTheme.backgroundColor,
      leading: IconButton(
        icon: Icon(RemixIcons.arrow_left_line),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(start: 50, bottom: 16),
        centerTitle: false,
        title: Text(
          c.editingEntry != null ? "av_edit_title".tr : "av_new_title".tr,
          style: GoogleFonts.lexend(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 11.sp,
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.primary.withOpacity(0.8),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  Widget _buildDropdowns(AddVehicleController c, ThemeData theme) {
    return Obx(
      () => _customDropdown(
        value: c.selectedTipos.value,
        label: "hp_select_fuel".tr,
        icon: RemixIcons.oil_line,
        theme: theme,
        items: c.tipos
            .map(
              (v) => DropdownMenuItem(
                value: '${v.id}',
                child: Text('${v.name}'),
              ),
            )
            .toList(),
        onChanged: (v) {
          c.selectedTipos.value = v;
        },
      ),
    );
  }

  Widget _customDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required ThemeData theme,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.secondary),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildInputField(AddVehicleController c, ThemeData theme) {
    return Column(
      children: [
        CustomTextField(
          controller: c.nameController,
          label: "av_name_label".tr,
          icon: RemixIcons.car_line,
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: c.licenseController,
                label: "av_plate_label".tr,
                icon: RemixIcons.shield_line,
              ),
            ),
            SizedBox(width: 15.h),
            Expanded(
              child: CustomTextField(
                controller: c.tankCapacityController,
                label: "av_tank_label".tr,
                icon: RemixIcons.oil_line,
                textInputType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        CustomTextField(
          controller: c.initialOdometerController,
          label: "av_odometer_label".tr,
          icon: RemixIcons.dashboard_line,
          textInputType: TextInputType.numberWithOptions(decimal: true),
        ),
        CustomTextField(
          controller: c.imagemController,
          label: "av_image_label".tr,
          icon: RemixIcons.image_line,
        ),
        _buildDropdowns(controller, theme),
      ],
    );
  }

  Widget _buildConnectionBanner() {
    return Obx(() {
      final isOnline = syncService.isOnline.value;
      final queueLength = syncService.pendingQueue.length;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isOnline ? Colors.green.shade900 : Colors.orange.shade900,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isOnline ? Colors.green.shade700 : Colors.orange.shade700,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isOnline ? RemixIcons.cloud_line : RemixIcons.cloud_off_line,
              color: isOnline ? Colors.green.shade300 : Colors.orange.shade300,
              size: 22.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnline
                        ? "hp_banner_online_title".tr
                        : "hp_banner_offline_title".tr,
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isOnline
                        ? "hp_banner_online_subtitle".tr
                        : "hp_banner_offline_subtitle".trParams({
                            'count': '$queueLength',
                          }),
                    style: GoogleFonts.lexend(
                      fontSize: 10.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
