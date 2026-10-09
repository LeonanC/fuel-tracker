import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/features/splash/controllers/splash_controller.dart';
import 'package:fuel_tracker/features/widgets/app_name_widget.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppNameWidget(
              greenTileColor: Colors.white,
              isBold: true,
              textSize: 40,
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        RemixIcons.car_fill,
                        size: 70,
                        color: theme.colorScheme.primary,
                      ),
                      Icon(
                        RemixIcons.gas_station_fill,
                        size: 80,
                        color: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                  Obx(() {
                    if (controller.temErro.value) {
                      return const SizedBox.shrink();
                    }

                    return Text(
                      '${controller.progresso.value}%',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    );
                  }),

                  Obx(() {
                    return SizedBox(height: controller.temErro.value ? 0 : 15);
                  }),

                  Obx(
                    () => Text(
                      controller.statusMensagem.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: controller.temErro.value
                            ? Colors.redAccent.withOpacity(0.9)
                            : Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Obx(() {
                    if (controller.temErro.value) {
                      return ElevatedButton.icon(
                        onPressed: () => controller.tentarNovamente,
                        icon: Icon(RemixIcons.refresh_line, size: 18),
                        label: Text('TENTAR NOVAMENTE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                      );
                    }
                    return _buildProgressBar(Colors.blueAccent);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(Color primaryColor) {
    return Container(
      width: double.infinity,
      height: 6.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
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
                  width:
                      constraints.maxWidth * (controller.progresso.value / 100),
                  height: 6.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3b82f6), Color(0xFF22D3EE)],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 2),
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
