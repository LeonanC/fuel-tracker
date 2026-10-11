import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/features/splash/controllers/splash_controller.dart';
import 'package:fuel_tracker/features/widgets/app_name_widget.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.scaffoldBackgroundColor,
              colorScheme.surface.withOpacity(0.5),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppNameWidget(
                greenTileColor: colorScheme.primary,
                isBold: true,
                textSize: 36.sp,
              ),
              SizedBox(height: 40.h),
              Container(
                padding: EdgeInsets.all(28.r),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(28.r),
                  border: Border.all(
                    color: colorScheme.onSurface.withOpacity(0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          RemixIcons.car_fill,
                          size: 56.sp,
                          color: colorScheme.primary,
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          RemixIcons.gas_station_fill,
                          size: 64.sp,
                          color: colorScheme.secondary,
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Obx(() {
                      if (controller.temErro.value) {
                        return const SizedBox.shrink();
                      }

                      return Text(
                        '${controller.progresso.value}%',
                        style: GoogleFonts.lexend(
                          fontSize: 32.sp,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      );
                    }),
                    Obx(() {
                      return SizedBox(
                        height: controller.temErro.value ? 0 : 12.h,
                      );
                    }),
                    Obx(
                      () => Text(
                        controller.statusMensagem.value,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          color: controller.temErro.value
                              ? Colors.redAccent.shade700
                              : colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Obx(() {
                      if (controller.temErro.value) {
                        return ElevatedButton.icon(
                          onPressed: () => controller.tentarNovamente,
                          icon: Icon(RemixIcons.refresh_line, size: 18.sp),
                          label: Text(
                            'TENTAR NOVAMENTE',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            minimumSize: Size(double.infinity, 48.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 2,
                          ),
                        );
                      }
                      return _buildProgressBar(colorScheme);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 6.h,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Obx(
                () => AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  width: constraints.maxWidth * (controller.progresso.value / 100),
                  height: 6.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 10.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
