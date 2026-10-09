import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/core/models/fuel_model.dart';
import 'package:fuel_tracker/core/network/app_router.dart';
import 'package:fuel_tracker/core/services/utils_service.dart';
import 'package:fuel_tracker/core/theme/app_colors.dart';
import 'package:fuel_tracker/features/fuel/controllers/home_controller.dart';
import 'package:fuel_tracker/features/widgets/custom_button_widget.dart';
import 'package:fuel_tracker/features/widgets/fuel_card.dart';
import 'package:fuel_tracker/features/widgets/list_filter_menu.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: RefreshIndicator(
        onRefresh: () => controller.fetchData(),
        edgeOffset: 100.h,
        color: theme.primaryColor,
        backgroundColor: theme.cardColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context, theme),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    _buildHeroStats(),
                    _buildSearchBar(theme),
                  ],
                ),
              ),
            ),
            _buildMainList(theme),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ThemeData theme) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SliverAppBar(
      expandedHeight: 60.h + topPadding,
      floating: true,
      pinned: true,
      elevation: 0,
      stretch: true,
      centerTitle: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double percentage =
              (constraints.maxHeight - kToolbarHeight - topPadding) / (120.h);
          return FlexibleSpaceBar(
            titlePadding: EdgeInsetsDirectional.only(
              start: 16.w,
              bottom: 16.h * (1 - percentage).clamp(0.2, 1.0),
            ),
            centerTitle: false,
            title: Text(
              'ab_title'.tr,
              style: GoogleFonts.lexend(
                color: theme.textTheme.displaySmall?.color,
                fontWeight: FontWeight.w800,
                fontSize: 26.sp,
                letterSpacing: -1.0,
              ),
            ),
            background: Container(color: theme.scaffoldBackgroundColor),
          );
        },
      ),
      actions: [
        FuelListFilterMenu(),
        CustomCircleButton(
          icon: RemixIcons.information_line,
          theme: theme,
          onPressed: () => Get.toNamed(PagesRoutes.aboutRoute),
        ),
        SizedBox(width: 16.w),
      ],
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.navigateToAddEntry(context),
          borderRadius: BorderRadius.circular(30.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 18.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(RemixIcons.add_line, color: Colors.white, size: 20.r),
                SizedBox(width: 12.w),
                Text(
                  "hp_new_registry".tr,
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStats() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF232931), Color(0xFF14171C)],
          ),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 25.r,
              offset: Offset(0, 10.h),
            )
          ]
        ),
        child: Column(
          children: [
            Row(
              children: [
                _statTile(
                  RemixIcons.dashboard_line,
                  Color(0xFF3366FF),
                  "hp_general_media".tr,
                  UtilsService().formatarConsumo(controller.mediaConsumoGeral),
                ),
                SizedBox(width: 16.w),
                _statTile(
                  RemixIcons.gas_station_line,
                  Color(0xFF80BFA5),
                  "hp_total_fueled".tr,
                  UtilsService().formatarVolume(
                    controller.totalLitrosAbastecidos,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(color: Colors.white.withOpacity(0.08), height: 1.h),
            SizedBox(height: 16.h),
            Row(
              children: [
                _statTile(
                  RemixIcons.price_tag_line,
                  Color(0xFFFFB020),
                  "hp_avg_price".tr,
                  UtilsService().formatarCurrency(
                    controller.precoMedioPorLitro,
                  ),
                ),
                SizedBox(width: 16.w),
                _statTile(
                  RemixIcons.calendar_check_line,
                  Color(0xFFFF4842),
                  "hp_monthly_expense".tr,
                  UtilsService().formatarCurrency(controller.gastoMensal),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _statTile(IconData icon, Color color, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 14.r),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexend(
                    color: color.withOpacity(0.5),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.lexend(
                color: color.withOpacity(0.5),
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: TextField(
        onChanged: (v) => controller.searchText.value = v,
        style: GoogleFonts.lexend(
          fontSize: 15.sp,
          color: theme.textTheme.bodyMedium?.color,
        ),
        decoration: InputDecoration(
          hintText: "hp_buscar_hint".tr,
          prefixIcon: Icon(RemixIcons.search_line, size: 20.r, color: theme.dividerColor),
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.05)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.05)),
          ),
        ),
        
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme){
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32.r),
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(RemixIcons.car_line, size: 40.r, color: theme.disabledColor.withOpacity(0.4)),
                  Icon(RemixIcons.gas_station_line, size: 60.r, color: theme.disabledColor.withOpacity(0.4)),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "hp_no_vehicle_found".tr,
              style: GoogleFonts.lexend(
                color: theme.disabledColor.withOpacity(0.6),
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            )
          ],
        ),
      ),
    );
  }

  Map<String, List<FuelModel>> _agruparFuelPorData(List<FuelModel> fuels){
    Map<String, List<FuelModel>> grupos = {};
    DateTime hoje = DateTime.now();
    DateTime ontem = hoje.subtract(const Duration(days: 1));

    for(var fuel in fuels){
      DateTime dataFuel = fuel.entryDate!;
      String dataFormatada;

      if(DateUtils.isSameDay(dataFuel, hoje)){
        dataFormatada = "hp_date_today".tr;
      } else if (DateUtils.isSameDay(dataFuel, ontem)){
        dataFormatada = "hp_date_yesterday".tr;
      }else {
        dataFormatada = DateFormat('dd MMMM yyyy', 'pt_BR').format(dataFuel);
      }

      if(grupos[dataFormatada] == null) grupos[dataFormatada] = [];
      grupos[dataFormatada]!.add(fuel);
    }

    return grupos;
  }

  Widget _buildMainList(ThemeData theme){
    return Obx((){
      final entries = controller.filteredFuelEntries;
      if(entries.isEmpty){
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(theme),
        );
      }

      final fuelsAgrupadas = _agruparFuelPorData(entries);
      final datas = fuelsAgrupadas.keys.toList();

      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index){
            final dataFormatada = datas[index];
            final fuelsDoDia = fuelsAgrupadas[dataFormatada]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateHeader(theme, dataFormatada),
                ...fuelsDoDia.map((fuel){
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: FuelCard(entry: fuel, controller: controller),
                  );
                }),
                SizedBox(height: 8.h),
              ],
            );
          }, childCount: datas.length),
        ),
      );
    });
  }

  Widget _buildDateHeader(ThemeData theme, String titulo){
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 12.h),
      child: Text(
        titulo,
        style: GoogleFonts.lexend(
          color: theme.textTheme.bodySmall!.color!.withOpacity(0.5),
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
