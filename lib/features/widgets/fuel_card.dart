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
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Stack(
        children: [
          Dismissible(
            key: Key(
              entry.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => controller.deleteFuel(entry.id!),
            background: _buildDeleteBackground(),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: () => controller.navigateToEditEntry(context, entry),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, vehicle, theme),
                        const Divider(height: 32, thickness: 0.5),
                        _rowInfo(
                          RemixIcons.map_line,
                          station,
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if(entry.isFullTank == true) ... [
                                _fullTankBadge(),
                                SizedBox(width: 6.w),
                              ],
                              _badge(fuelType),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _miniStat(
                              "hp_odometer".tr,
                              UtilsService().formatarDistancia(entry.odometerKm!.toDouble()),
                            ),
                            _miniStat(
                              "hp_volume".tr,
                              UtilsService().formatarVolume(entry.volumeLiters!),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _priceFooter(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 25),
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.redAccent.shade400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(RemixIcons.delete_bin_line, color: Colors.white),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Map<String, dynamic>? vehicle,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${vehicle?['name']}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _plateWidget(
              vehicle?['license_plate'] ?? "",
            ),
          ],
        ),
      ],
    );
  }

  Widget _fullTankBadge(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        "hp_label_full_tank".tr,
        style: GoogleFonts.lexend(
          fontSize: 9,
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _rowInfo(IconData icon, String text, Widget trailing) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueAccent),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _badge(String label){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 10)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _priceFooter(ThemeData theme){
    String dataFormatada = '---';
    if(entry.entryDate != null){
      if(entry.entryDate is DateTime){
        dataFormatada = DateFormat('dd/MM/yyyy').format(entry.entryDate as DateTime);
      }else if (entry.entryDate is String){
        dataFormatada = DateFormat('dd/MM/yyyy').format(DateTime.parse(entry.entryDate as String));
      }
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Data", style: TextStyle(fontSize: 9, color: Colors.grey)),
              Text(
                dataFormatada,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Preço/L", style: TextStyle(fontSize: 9, color: Colors.grey)),
              Text(
                UtilsService().formatarCurrency(entry.pricePerLiter!),
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total pago", style: TextStyle(fontSize: 9, color: Colors.grey)),
              Text(
                UtilsService().formatarCurrency(entry.totalCost!),
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _plateWidget(String plate) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(width: 1),
      ),
      child: Text(
        plate,
        style: GoogleFonts.lexend(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
