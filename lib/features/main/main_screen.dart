import 'package:flutter/material.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  List<Widget> get pages => [HomePage(), ProfilePage(), SettingPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    double scrennWidth = MediaQuery.of(context).size.width;
    bool isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: GNav(
            gap: scrennWidth < 360 ? 4 : 8,
            iconSize: scrennWidth < 360 ? 20 : 24,
            curve: Curves.easeOutExpo,
            rippleColor: theme.dividerColor.withOpacity(0.1),
            hoverColor: theme.dividerColor.withOpacity(0.05),
            haptic: true,
            tabBorderRadius: 28,
            activeColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(
              horizontal: scrennWidth < 360 ? 10 : 20,
              vertical: 12,
            ),
            tabBackgroundColor: Colors.blueAccent.withOpacity(0.1),
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
            tabs: [
              GButton(
                icon: _selectedIndex == 0
                    ? RemixIcons.truck_fill
                    : RemixIcons.truck_line,
                text: "nav_fuel_entries".tr,
                textStyle: GoogleFonts.lexend(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: scrennWidth < 360 ? 11 : 13,
                ),
              ),
              GButton(
                icon: _selectedIndex == 1
                    ? RemixIcons.user_fill
                    : RemixIcons.user_line,
                text: "nav_perfil".tr,
                textStyle: GoogleFonts.lexend(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: scrennWidth < 360 ? 11 : 13,
                ),
              ),
              GButton(
                icon: _selectedIndex == 2
                    ? RemixIcons.settings_fill
                    : RemixIcons.settings_line,
                text: "nav_setting".tr,
                textStyle: GoogleFonts.lexend(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: scrennWidth < 360 ? 11 : 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
