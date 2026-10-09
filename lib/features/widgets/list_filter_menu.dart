import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/features/fuel/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class FuelListFilterMenu extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopupMenuButton<String>(
      icon: Icon(RemixIcons.filter_line, color: colorScheme.onSurface),
      tooltip: "hp_tooltip".tr,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      offset: Offset(0, 45),
      onSelected: (value) => _handleSelection(value),
      itemBuilder: (BuildContext context) {
        return [
          _buildSectionHeader(
            RemixIcons.car_line,
            "hp_vehicles".tr,
            colorScheme,
          ),
          ...controller.veiculosMap.entries.map((entry) {
            return _buildFilterItem(
              value: 'SetVeiculo:${entry.key}',
              label: '${entry.value["name"]}',
              isSelected: controller.selectedVehicleId.value == entry.key,
              colorScheme: colorScheme,
            );
          }),
          _buildClearItem(
            "ClearVeiculo",
            "hp_clear_vehicle".tr,
            controller.selectedVehicleId.value != null,
          ),
          const PopupMenuDivider(),
          _buildSectionHeader(
            RemixIcons.gas_station_line,
            "hp_fuel".tr,
            colorScheme,
          ),
          ...controller.tiposMap.entries.map((entry) {
            return _buildFilterItem(
              value: 'SetFuel:${entry.key}',
              label: '${entry.value["nome"]}',
              isSelected: controller.selectedTipoId.value == entry.key,
              colorScheme: colorScheme,
            );
          }),
          _buildClearItem(
            "ClearFuel",
            "hp_clear_fuel".tr,
            controller.selectedTipoId.value != null,
          ),
          const PopupMenuDivider(),
          _buildSectionHeader(
            RemixIcons.map_line,
            "hp_station".tr,
            colorScheme,
          ),
          ...controller.tiposMap.entries.map((entry) {
            return _buildFilterItem(
              value: 'SetStation:${entry.key}',
              label: '${entry.value["nome"]}',
              isSelected: controller.selectedPostoId.value == entry.key,
              colorScheme: colorScheme,
            );
          }),
          _buildClearItem(
            "ClearStation",
            "hp_clear_station".tr,
            controller.selectedPostoId.value != null,
          ),
        ];
      },
    );
  }

  void _handleSelection(String value) {
    if (value.startsWith('SetVeiculo:')) {
      controller.selectedVehicleId.value = value.split(':')[1];
    } else if (value == 'ClearVeiculo') {
      controller.selectedVehicleId.value = null;
    } else if (value.startsWith('SetFuel:')) {
      controller.selectedTipoId.value = value.split(':')[1];
    } else if (value == 'ClearFuel') {
      controller.selectedTipoId.value = null;
    } else if (value.startsWith('SetStation:')) {
      controller.selectedPostoId.value = value.split(':')[1];
    } else if (value == 'ClearStation') {
      controller.selectedPostoId.value = null;
    }
  }

  PopupMenuItem<String> _buildSectionHeader(
    IconData icon,
    String title,
    ColorScheme color,
  ) {
    return PopupMenuItem(
      enabled: false,
      height: 32,
      child: Row(
        children: [
          Icon(icon, size: 14, color: color.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: color.primary,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildFilterItem({
    required String value,
    required String label,
    required bool isSelected,
    required ColorScheme colorScheme,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? RemixIcons.checkbox_circle_fill
                  : RemixIcons.checkbox_circle_line,
              size: 18,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildClearItem(String value, String label, bool isVisible){
    if(!isVisible)
      return PopupMenuItem(enabled: false, height: 0, child: SizedBox.shrink());
    
    return PopupMenuItem(
      value: value,
      height: 35,
      child: Padding(
        padding: EdgeInsets.only(left: 30),
        child: Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
