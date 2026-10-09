import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/core/network/app_router.dart';
import 'package:fuel_tracker/core/services/validator.dart';
import 'package:fuel_tracker/features/auth/controllers/auth_controller.dart';
import 'package:fuel_tracker/features/widgets/app_name_widget.dart';
import 'package:fuel_tracker/features/widgets/custom_text_field.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class SignInPage extends GetView<AuthController> {
  SignInPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: 1.sh,
          width: 1.sw,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppNameWidget(
                      greenTileColor: theme.colorScheme.primary,
                      textSize: 40.sp,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          RemixIcons.car_line,
                          size: 60.r,
                          color: theme.colorScheme.primary,
                        ),
                        Icon(
                          RemixIcons.gas_station_line,
                          size: 80.r,
                          color: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
                decoration: BorderRadius.vertical(
                  top: Radius.circular(45.r),
                ).toBoxDecoration(color: Colors.white),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextField(
                        controller: emailController,
                        icon: RemixIcons.mail_line,
                        label: "E-mail",
                        validator: emailValidator,
                      ),
                      CustomTextField(
                        controller: passwordController,
                        icon: RemixIcons.lock_line,
                        isSecret: true,
                        label: "Senha",
                        validator: passwordValidator,
                      ),

                      SizedBox(
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isLoading.value
                            ? null
                            : () async {
                              if(_formKey.currentState!.validate()){
                                FocusScope.of(context).unfocus();
                                bool success = await controller.signIn(
                                  email: emailController.text.trim(), 
                                  password: passwordController.text,
                                );

                                if(success){
                                  Get.offAllNamed(PagesRoutes.mainRoute);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              minimumSize: Size(double.infinity, 55.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                            ),
                            child: controller.isLoading.value
                            ? SizedBox(
                              height: 24.r,
                              width: 24.r,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'lg_entrar'.tr,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Esqueci a senha',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: theme.colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(PagesRoutes.signUpRoute),
                        child: Text(
                          'Não tem conta?',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: theme.colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on BorderRadius {
  BoxDecoration toBoxDecoration({required Color color}) {
    return BoxDecoration(color: color, borderRadius: this);
  }
}
