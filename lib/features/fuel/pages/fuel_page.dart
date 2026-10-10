import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/features/fuel/controllers/add_controller.dart';
import 'package:fuel_tracker/features/fuel/services/offline_sync_service.dart';
import 'package:fuel_tracker/features/notification/controllers/notification_controller.dart';
import 'package:fuel_tracker/features/widgets/custom_text_field.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

class FuelPage extends GetView<AddController> {
  FuelPage({super.key});

  final notifController = Get.find<NotifController>();
  final syncService = Get.find<OfflineSyncService>();

  void _handleSaveAndNotify() async {
    await controller.submit();
    if (notifController.refuelReminders.value) {
      notifController.showNotification(
        id: 101,
        title: 'hp_notify_title_success'.tr,
        body: syncService.isOnline.value
            ? 'hp_notify_body_online'.tr
            : 'hp_notify_body_offline'.tr,
      );
    }

    if (notifController.oilChangeAlerts.value) {
      final kmStr = controller.kmController.text;
      if (kmStr.isNotEmpty) {
        final double? km = double.tryParse(kmStr);
        if (km != null && km > 10000) {
          notifController.showNotification(
            id: 103,
            title: 'hp_notify_title_oil'.tr,
            body: 'hp_notify_body_oil'.tr,
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: ElevatedButton.icon(
              onPressed: (controller.isLoading.value || (!isOnline && isFull))
                  ? null
                  : _handleSaveAndNotify,
              style: ElevatedButton.styleFrom(
                backgroundColor: !isOnline
                    ? Colors.orange.shade700
                    : theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: Size.fromHeight(54.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 4,
                shadowColor:
                    (isOnline ? theme.colorScheme.primary : Colors.orange)
                        .withOpacity(0.4),
              ),
              icon: controller.isLoading.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      !isOnline
                          ? RemixIcons.cloud_off_line
                          : RemixIcons.check_line,
                      color: theme.colorScheme.onPrimary,
                      size: 20.sp,
                    ),
              label: Text(
                !isOnline
                    ? 'hp_btn_save_offline'.trParams({
                        'current': '${syncService.pendingQueue.length}',
                        'max': '${syncService.maxQueueSize}',
                      })
                    : controller.editingEntry != null
                    ? "hp_btn_edit".tr
                    : "hp_btn_add".tr,
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: theme.colorScheme.onPrimary,
                  letterSpacing: 0.8,
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
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 40.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("hp_section_vehicle_location".tr, theme),
                    _buildCardContainer(
                      theme,
                      child: _buildDropdowns(controller, theme),
                    ),
                    SizedBox(height: 24.h),
                    _buildSectionTitle(
                      "hp_section_measurement_values".tr,
                      theme,
                    ),
                    _buildCardContainer(
                      theme,
                      child: _buildInputField(controller, theme),
                    ),
                    SizedBox(height: 24.h),
                    _buildConnectionBanner(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(AddController c, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 60.h,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: theme.appBarTheme.backgroundColor,
      leading: IconButton(
        icon: Icon(
          RemixIcons.arrow_left_line,
          color: theme.colorScheme.onSurface,
        ),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(start: 50.w, bottom: 16.h),
        centerTitle: false,
        title: Text(
          c.editingEntry != null ? "hp_title_edit".tr : "hp_title_add".tr,
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
      padding: EdgeInsets.fromLTRB(4.w, 8.h, 4.w, 12.h),
      child: Row(
        children: [
          Container(
            width: 3.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.lexend(
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer(ThemeData theme, {required Widget child}) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDropdowns(AddController c, ThemeData theme) {
    return Obx(
      () => Column(
        children: [
          _customDropdown(
            value: c.selectedVeiculos.value,
            label: "hp_select_vehicle".tr,
            icon: RemixIcons.car_line,
            theme: theme,
            items: c.veiculos
                .map(
                  (v) => DropdownMenuItem(
                    value: '${v.id}',
                    child: Text(
                      '${v.name}',
                      style: GoogleFonts.lexend(
                        fontSize: 13.sp,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              c.selectedVeiculos.value = v;
              c.atualizarHodometroPorVeiculo(v);
            },
          ),
          SizedBox(height: 15.h),
          _customDropdown(
            value: c.selectedPostos.value,
            label: "hp_select_gas_station".tr,
            icon: RemixIcons.gas_station_line,
            theme: theme,
            items: c.postos
                .map(
                  (v) => DropdownMenuItem(
                    value: '${v.id}',
                    child: Text(
                      '${v.name}',
                      style: GoogleFonts.lexend(
                        fontSize: 13.sp,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              c.selectedPostos.value = v;
            },
          ),
          SizedBox(height: 15.h),
          _customDropdown(
            value: c.selectedTipos.value,
            label: "hp_select_fuel".tr,
            icon: RemixIcons.oil_line,
            theme: theme,
            items: c.tipos
                .map(
                  (v) => DropdownMenuItem(
                    value: '${v.id}',
                    child: Text(
                      '${v.name}',
                      style: GoogleFonts.lexend(
                        fontSize: 13.sp,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              c.selectedTipos.value = v;
            },
          ),
        ],
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
      isExpanded: true,
      dropdownColor: theme.colorScheme.surface,
      icon: Icon(
        RemixIcons.arrow_down_s_line,
        size: 18.sp,
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
      style: GoogleFonts.lexend(
        fontSize: 13.sp,
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lexend(
          fontSize: 12.sp,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        floatingLabelStyle: GoogleFonts.lexend(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Icon(icon, size: 20.sp, color: theme.colorScheme.primary),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 40.w, minHeight: 20.h),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.06),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.06),
            width: 1.5,
          ),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildInputField(AddController c, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: c.kmController,
          label: "hp_current_odometer".tr,
          icon: RemixIcons.dashboard_line,
          textInputType: TextInputType.numberWithOptions(decimal: true),
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: c.litrosController,
                label: "hp_label_liters".tr,
                icon: RemixIcons.drop_line,
                textInputType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomTextField(
                controller: c.precoPorLitroController,
                label: "hp_label_price_per_liter".tr,
                icon: RemixIcons.price_tag_2_line,
                textInputType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        CustomTextField(
          controller: c.totalPrecoController,
          label: "hp_label_total_price".tr,
          icon: RemixIcons.price_tag_3_line,
          textInputType: TextInputType.numberWithOptions(decimal: true),
        ),
        SizedBox(height: 4.h),
        _buildFullTankSwitch(c, theme),
        SizedBox(height: 14.h),
        _buildDatePickerField(c, theme),
      ],
    );
  }

  Widget _buildFullTankSwitch(AddController c, ThemeData theme) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: SwitchListTile(
          value: c.isFullTank.value,
          onChanged: (v) => c.isFullTank.value = v,
          title: Text(
            "hp_label_full_tank".tr,
            style: GoogleFonts.lexend(
              color: theme.colorScheme.onSurface,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          secondary: Icon(
            RemixIcons.gas_station_fill,
            color: theme.colorScheme.primary,
            size: 20.sp,
          ),
          activeColor: theme.colorScheme.primary,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(AddController c, ThemeData theme) {
    return Obx(() {
      final date = c.selectedDate.value;
      final dateStr = DateFormat('dd/MM/yyyy').format(date);
      final timeStr = DateFormat('HH:mm').format(date);
      return InkWell(
        onTap: () => c.selecionarData(Get.context!),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: theme.colorScheme.onSurface.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  RemixIcons.calendar_event_line,
                  size: 20.sp,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "hp_supply_date".tr,
                      style: GoogleFonts.lexend(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "$dateStr às $timeStr",
                      style: GoogleFonts.lexend(
                        color: theme.colorScheme.onSurface,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(RemixIcons.arrow_right_s_line, size: 18.sp, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildConnectionBanner(ThemeData theme) {
    return Obx(() {
      final isOnline = syncService.isOnline.value;
      final queueLength = syncService.pendingQueue.length;
      final bannerColor = isOnline ? Colors.green : Colors.orange;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: bannerColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: bannerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: bannerColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                isOnline ? RemixIcons.cloud_line : RemixIcons.cloud_off_line,
                color: bannerColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 14.w),
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
                      color: bannerColor,
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
                      fontSize: 11.sp,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
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
