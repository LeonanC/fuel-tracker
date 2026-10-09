import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/core/services/validator.dart';
import 'package:fuel_tracker/features/auth/controllers/auth_controller.dart';
import 'package:fuel_tracker/features/widgets/app_name_widget.dart';
import 'package:fuel_tracker/features/widgets/custom_text_field.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class ResetPassword extends GetView<AuthController> {
  ResetPassword({super.key});

  final _formKey = GlobalKey<FormState>();
  final authController = Get.find<AuthController>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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
                      textSize: 36.sp,
                    ),
                    SizedBox(height: 15.h),
                    Icon(
                      RemixIcons.lock_password_line,
                      size: 70.sp,
                      color: theme.colorScheme.primary,
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
                      Text(
                        'lg_nova_senha'.tr,
                        style: GoogleFonts.lexend(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'lg_instrucao_nova_senha'.tr,
                        style: GoogleFonts.lexend(
                          fontSize: 13.sp,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      CustomTextField(
                        controller: newPasswordController,
                        icon: RemixIcons.lock_line,
                        isSecret: true,
                        label: 'lg_nova_senha'.tr,
                        validator: passwordValidator,
                      ),
                      CustomTextField(
                        controller: confirmPasswordController,
                        icon: RemixIcons.lock_line,
                        isSecret: true,
                        label: 'lg_confirmar_nova_senha'.tr,
                        validator: (val){
                          final passwordError = passwordValidator(val);
                          if(passwordError != null) return passwordError;
                          if(val != newPasswordController.text){
                            return 'lg_senhas_nao_coincidem'.tr;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        child: Obx(() => ElevatedButton(
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if(_formKey.currentState!.validate()){
                              authController.updateNewPassword(
                                newPasswordController.text.trim(),
                              );                            
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.secondary,
                            minimumSize: Size(double.infinity,  55.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                          ),
                          child: controller.isLoading.value
                          ? SizedBox(
                            height: 24.r,
                            width: 24.r,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                          : Text(
                            'lg_salvar_nova_senha'.tr,
                            style: GoogleFonts.lexend(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        )),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

extension on BorderRadius {
  BoxDecoration toBoxDecoration({required Color color}){
    return BoxDecoration(color: color, borderRadius: this);
  }
}