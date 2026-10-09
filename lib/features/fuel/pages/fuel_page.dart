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
    if(notifController.refuelReminders.value){
      notifController.showNotification(
        id: 101,
        title: 'hp_notify_title_success'.tr,
        body: syncService.isOnline.value
        ? 'hp_notify_body_online'.tr
        : 'hp_notify_body_offline'.tr,
      );
    }

    if(notifController.oilChangeAlerts.value){
      final kmStr = controller.kmController.text;
      if(kmStr.isNotEmpty){
        final double? km = double.tryParse(kmStr);
        if(km != null && km > 10000){
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
                    ? "hp_btn_edit".tr
                    : "hp_btn_add".tr,
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
                    _buildSectionTitle("hp_section_vehicle_location".tr, theme),
                    _buildCardContainer(
                      child: _buildDropdowns(controller, theme),
                    ),
                    SizedBox(height: 20.h),
                    _buildSectionTitle(
                      "hp_section_measurement_values".tr,
                      theme,
                    ),
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

  Widget _buildSliverAppBar(AddController c, ThemeData theme) {
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
                    child: Text('${v.name}'),
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
                    child: Text('${v.name}'),
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
                    child: Text('${v.name}'),
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

  Widget _buildInputField(AddController c, ThemeData theme) {
    return Column(
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
            SizedBox(width: 15.h),
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
        _buildFullTankSwitch(c, theme),
        SizedBox(height: 15.h),
        _buildDatePickerField(c, theme),
      ],
    );
  }

  Widget _buildFullTankSwitch(AddController c, ThemeData theme) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SwitchListTile(
          value: c.isFullTank.value,
          onChanged: (v) => c.isFullTank.value = v,
          title: Text(
            "hp_label_full_tank".tr,
            style: GoogleFonts.lexend(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          secondary: Icon(
            RemixIcons.gas_station_fill,
            color: theme.colorScheme.secondary,
            size: 20.sp,
          ),
          activeColor: theme.colorScheme.primary,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
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
            color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Icon(
                RemixIcons.calendar_event_line,
                size: 20.sp,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 15.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "hp_supply_date".tr,
                    style: GoogleFonts.lexend(
                      color: Colors.white54,
                      fontSize: 10.sp,
                    ),
                  ),
                  Text(
                    "$dateStr às $timeStr",
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(RemixIcons.edit_line, size: 16.sp, color: Colors.white24),
            ],
          ),
        ),
      );
    });
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
