import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/core/services/utils_service.dart';
import 'package:fuel_tracker/features/about/controllers/about_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:remixicon/remixicon.dart';

class AboutPage extends StatelessWidget {
  AboutPage({super.key});

  final AboutController controller = Get.find<AboutController>();
  final UtilsService _utilsService = UtilsService();

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _utilsService.showToast(message: "ab_error_title".tr, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 60.h,
            pinned: true,
            elevation: 0,
            stretch: true,
            backgroundColor:
                theme.appBarTheme.backgroundColor ??
                theme.scaffoldBackgroundColor,
            leading: IconButton(
              icon: Icon(RemixIcons.arrow_left_line),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsetsDirectional.only(
                start: 50.w,
                bottom: 16.h,
              ),
              centerTitle: false,
              title: Text(
                'ab_about'.tr,
                style: GoogleFonts.lexend(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                children: [
                  _buildHeader(theme),
                  SizedBox(height: 32.h),
                  _buildSectionCard(
                    theme,
                    title: "ab_title".tr,
                    content: "ab_tagline".tr,
                  ),
                  SizedBox(height: 20.h),
                  _buildSectionCard(
                    theme,
                    title: "ab_info".tr,
                    child: Column(
                      children: [
                        Obx(
                          () => _buildInfoRow(
                            "ab_info_version_1".tr,
                            "${controller.appVersion.value}",
                          ),
                        ),
                        Divider(
                          color: Colors.white.withOpacity(0.05),
                          height: 24.h,
                        ),
                        _buildInfoRow("ab_info_version_2".tr, "Flutter & GetX"),
                        Divider(
                          color: Colors.white.withOpacity(0.05),
                          height: 24.h,
                        ),
                        _buildInfoRow("ab_info_version_3".tr, "Supabase"),
                        Divider(
                          color: Colors.white.withOpacity(0.05),
                          height: 24.h,
                        ),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 44.h,
                            child: ElevatedButton.icon(
                              onPressed: controller.isCheckingForUpdate.value
                                  ? null
                                  : () => controller.checkForUpdate(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary
                                    .withOpacity(0.15),
                                foregroundColor: theme.colorScheme.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: BorderSide(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.3),
                                  ),
                                ),
                              ),
                              icon: Icon(RemixIcons.refresh_line, size: 16.sp),
                              label: controller.isCheckingForUpdate.value
                                  ? SizedBox(
                                      width: 16.sp,
                                      height: 16.sp,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.primary,
                                      ),
                                    )
                                  : Text(
                                      controller.isCheckingForUpdate.value
                                          ? "A verificar..."
                                          : 'ab_update_available'.tr,
                                      style: GoogleFonts.lexend(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildSectionCard(
                    theme,
                    title: "Links e Suporte",
                    child: Column(
                      children: [
                        _buildActionTile(
                          icon: RemixIcons.github_line,
                          title: "Repositório no GitHub",
                          subtitle: "Ver código fonte ou reportar bugs",
                          onTap: () => _launchUrl(
                            'https://github.com/LeonanC/fuel-tracker',
                          ),
                          theme: theme,
                        ),
                        Divider(
                          color: Colors.white.withOpacity(0.05),
                          height: 24.h,
                        ),
                        _buildActionTile(
                          icon: RemixIcons.mail_line,
                          title: "Contacto de Suporte",
                          subtitle: "LeonanC@outlook.com.br",
                          onTap: () =>
                              _launchUrl('mailto:LeonanC@outlook.com.br'),
                          theme: theme,
                        ),
                        _buildActionTile(
                          icon: RemixIcons.shield_user_line,
                          title: "ab_privacyPolicy".tr,
                          onTap: () =>
                              _launchUrl('https://github.com/LeonanC/fuel-tracker/blob/main/privacy.md'),
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Text(
                    "${'ab_developed_by'.tr} ${'ab_developer'.tr}",
                    style: GoogleFonts.lexend(
                      color: Colors.white54,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "ab_copyright".tr,
                    style: GoogleFonts.lexend(
                      color: Colors.white24,
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            RemixIcons.gas_station_fill,
            size: 40.r,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          "ab_title".tr,
          style: GoogleFonts.lexend(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "ab_description".tr,
          style: GoogleFonts.lexend(fontSize: 12.sp, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    ThemeData theme, {
    required String title,
    String? content,
    Widget? child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary.withOpacity(0.9),
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
          if (content != null)
            Text(
              content,
              style: GoogleFonts.lexend(
                fontSize: 13.sp,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(fontSize: 13.sp, color: Colors.white54),
        ),
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lexend(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.lexend(
                        fontSize: 11.sp,
                        color: Colors.white54,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              RemixIcons.arrow_right_s_line,
              color: Colors.white30,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}
