import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/core/models/fuel_model.dart';
import 'package:fuel_tracker/core/network/app_router.dart';
import 'package:fuel_tracker/core/services/utils_service.dart';
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        floatingActionButton: _buildFAB(context, theme),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.scaffoldBackgroundColor,
                theme.colorScheme.surface.withOpacity(0.3),
              ],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () => controller.fetchData(),
            edgeOffset: 100.h,
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surface,
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
                        _buildHeroStats(theme),
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
                color: theme.colorScheme.onSurface,
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

  Widget _buildFAB(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.4),
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
                Icon(
                  RemixIcons.add_line,
                  color: theme.colorScheme.onPrimary,
                  size: 20.r,
                ),
                SizedBox(width: 12.w),
                Text(
                  "hp_new_registry".tr,
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStats(ThemeData theme) {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 25.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _statTile(
                  theme,
                  RemixIcons.dashboard_line,
                  theme.colorScheme.primary,
                  "hp_general_media".tr,
                  UtilsService().formatarConsumo(controller.mediaConsumoGeral),
                ),
                _statTile(
                  theme,
                  RemixIcons.calendar_check_line,
                  theme.colorScheme.secondary,
                  "hp_average_cost".tr,
                  UtilsService().formatarCurrency(controller.custoPorKm),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _statTile(
    ThemeData theme,
    IconData icon,
    Color color,
    String label,
    String value,
  ) {
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
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                color: theme.colorScheme.onSurface,
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

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: TextField(
        onChanged: (v) => controller.searchText.value = v,
        style: GoogleFonts.lexend(
          fontSize: 15.sp,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: "hp_buscar_hint".tr,
          prefixIcon: Icon(
            RemixIcons.search_line,
            size: 20.r,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 18.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide(
              color: theme.colorScheme.onSurface.withOpacity(0.05),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide(
              color: theme.colorScheme.onSurface.withOpacity(0.05),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(28.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 70.r,
                    height: 70.r,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        RemixIcons.car_line,
                        size: 34.r,
                        color: theme.colorScheme.primary.withOpacity(0.7),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        RemixIcons.gas_station_fill,
                        size: 52.r,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              "hp_no_vehicle_found".tr,
              style: GoogleFonts.lexend(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              "Adicione um registro para começar",
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<FuelModel>> _agruparFuelPorData(List<FuelModel> fuels) {
    Map<String, List<FuelModel>> grupos = {};
    DateTime hoje = DateTime.now();
    DateTime ontem = hoje.subtract(const Duration(days: 1));

    for (var fuel in fuels) {
      if(fuel.entryDate == null) continue;

      final DateTime dataFuel = fuel.entryDate!;
      late final String dataFormatada;

      if (DateUtils.isSameDay(dataFuel, hoje)) {
        dataFormatada = "hp_date_today".tr;
      } else if (DateUtils.isSameDay(dataFuel, ontem)) {
        dataFormatada = "hp_date_yesterday".tr;
      } else {
        dataFormatada = DateFormat("d 'de' MMMM, yyyy", 'pt_BR').format(dataFuel);
      }

      grupos.putIfAbsent(dataFormatada, () => []).add(fuel);
    }
    return grupos;
  }

  Widget _buildMainList(ThemeData theme) {
    return Obx(() {
      final entries = controller.filteredFuelEntries;
      if (entries.isEmpty) {
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
          delegate: SliverChildBuilderDelegate((context, index) {
            final dataFormatada = datas[index];
            final fuelsDoDia = fuelsAgrupadas[dataFormatada]!;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child){
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(theme, dataFormatada),
                  ...fuelsDoDia.map((fuel) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: FuelCard(entry: fuel, controller: controller),
                    );
                  }),
                  SizedBox(height: 12.h),
                ],
              ),
            );
          }, childCount: datas.length),
        ),
      );
    });
  }

  Widget _buildDateHeader(ThemeData theme, String titulo) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            titulo.toUpperCase(),
            style: GoogleFonts.lexend(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(child: Divider(color: theme.colorScheme.onSurface.withOpacity(0.06), thickness: 1)),
        ],
      ),
    );
  }
}
