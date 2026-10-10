import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/core/models/fuel_model.dart';
import 'package:fuel_tracker/core/services/utils_service.dart';
import 'package:fuel_tracker/features/fuel/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

class FuelCard extends StatelessWidget {
  final FuelModel entry;
  final HomeController controller;
  const FuelCard({super.key, required this.entry, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehicle = controller.veiculosMap[entry.vehicleId];
    final station = controller.postosMap[entry.gasStationId]?['nome'] ?? '---';
    final fuelType = controller.tiposMap[entry.fuelTypeId]?['nome'] ?? '---';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
      child: Dismissible(
        key: Key(entry.id ?? DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => controller.deleteFuel(entry.id!),
        background: _buildDeleteBackground(theme),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: theme.colorScheme.onSurface.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () => controller.navigateToEditEntry(context, entry),
              child: Padding(
                padding: EdgeInsets.all(18.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, vehicle, theme),
                    Divider(
                      height: 28.h,
                      thickness: 1,
                      color: theme.colorScheme.onSurface.withOpacity(0.05),
                    ),
                    _rowInfo(
                      theme,
                      RemixIcons.map_line,
                      station,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (entry.isFullTank == true) ...[
                            _fullTankBadge(theme),
                            SizedBox(width: 6.w),
                          ],
                          _badge(theme, fuelType),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _miniStat(
                          theme,
                          "hp_odometer".tr,
                          UtilsService().formatarDistancia(
                            entry.odometerKm.toDouble(),
                          ),
                        ),
                        _miniStat(
                          theme,
                          "hp_volume".tr,
                          UtilsService().formatarVolume(entry.volumeLiters),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _priceFooter(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteBackground(ThemeData theme) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 24.w),
      decoration: BoxDecoration(
        color: Colors.redAccent.shade700,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Icon(RemixIcons.delete_bin_line, color: Colors.white, size: 24.r),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Map<String, dynamic>? vehicle,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '${vehicle?['name'] ?? 'Veículo'}',
            style: GoogleFonts.lexend(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        _plateWidget(theme, vehicle?['license_plate'] ?? ""),
      ],
    );
  }

  Widget _fullTankBadge(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        border: Border.all(color: Colors.green.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        "hp_label_full_tank".tr,
        style: GoogleFonts.lexend(
          fontSize: 9.sp,
          color: Colors.greenAccent.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _rowInfo(
    ThemeData theme,
    IconData icon,
    String text,
    Widget trailing,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: theme.colorScheme.primary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lexend(
              fontSize: 13.sp,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _badge(ThemeData theme, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.lexend(
          fontSize: 9.sp,
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _miniStat(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: GoogleFonts.lexend(
            color: theme.colorScheme.onSurface,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _priceFooter(ThemeData theme) {
    String dataFormatada = '---';
    if (entry.entryDate != null) {
      if (entry.entryDate is DateTime) {
        dataFormatada = DateFormat(
          'dd/MM/yyyy',
        ).format(entry.entryDate as DateTime);
      } else if (entry.entryDate is String) {
        dataFormatada = DateFormat(
          'dd/MM/yyyy',
        ).format(DateTime.parse(entry.entryDate as String));
      }
    }

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.04),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _footerItem(
            theme,
            label: "Data",
            value: dataFormatada,
            icon: RemixIcons.calendar_line,
          ),
          _footerItem(
            theme,
            label: "Preço/L",
            value: UtilsService().formatarCurrency(entry.pricePerLiter),
            icon: RemixIcons.percent_line,
          ),
          _footerItem(
            theme,
            label: "Total pago",
            value: UtilsService().formatarCurrency(entry.totalCost),
            icon: RemixIcons.money_dollar_circle_line,
          ),
        ],
      ),
    );
  }

  Widget _footerItem(
    ThemeData theme, {
    required String label,
    required String value,
    required IconData icon,
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 11.sp,
              color: isHighlight
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 10.sp,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: isHighlight
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _plateWidget(ThemeData theme, String plate) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Text(
        plate,
        style: GoogleFonts.lexend(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 11.sp,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
