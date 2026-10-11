import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/features/fuel/pages/home_page.dart';
import 'package:fuel_tracker/features/profile/page/profile_page.dart';
import 'package:fuel_tracker/features/settings/pages/settings_page.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:remixicon/remixicon.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final RxInt _currentIndex = 0.obs;

  List<Widget> get pages => [HomePage(), ProfilePage(), SettingPage()];

  void _onItemTapped(int index) {
    _currentIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() => pages[_currentIndex.value]),
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    double scrennWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        border: Border.all(
          color: colorScheme.onSurface.withOpacity(0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20.r,
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Obx(
            () => GNav(
              gap: scrennWidth < 360 ? 4 : 8,
              iconSize: scrennWidth < 360 ? 20.sp : 22.sp,
              curve: Curves.easeOutExpo,
              rippleColor: colorScheme.primary.withOpacity(0.1),
              hoverColor: colorScheme.primary.withOpacity(0.05),
              haptic: true,
              tabBorderRadius: 20.r,
              activeColor: colorScheme.primary,
              color: colorScheme.onSurface.withOpacity(0.5),
              padding: EdgeInsets.symmetric(
                horizontal: scrennWidth < 360 ? 12.w : 16.w,
                vertical: 10.h,
              ),
              tabBackgroundColor: colorScheme.primary.withOpacity(0.12),
              selectedIndex: _currentIndex.value,
              onTabChange: _onItemTapped,
              tabs: [
                GButton(
                  icon: _currentIndex.value == 0
                      ? RemixIcons.truck_fill
                      : RemixIcons.truck_line,
                  text: "nav_fuel_entries".tr,
                  textStyle: GoogleFonts.lexend(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: scrennWidth < 360 ? 11.sp : 12.sp,
                  ),
                ),
                GButton(
                  icon: _currentIndex.value == 1
                      ? RemixIcons.user_fill
                      : RemixIcons.user_line,
                  text: "nav_perfil".tr,
                  textStyle: GoogleFonts.lexend(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: scrennWidth < 360 ? 11.sp : 12.sp,
                  ),
                ),
                GButton(
                  icon: _currentIndex.value == 2
                      ? RemixIcons.settings_fill
                      : RemixIcons.settings_line,
                  text: "nav_setting".tr,
                  textStyle: GoogleFonts.lexend(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: scrennWidth < 360 ? 11.sp : 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
