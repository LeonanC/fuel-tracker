import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/core/models/user_model.dart';
import 'package:fuel_tracker/core/network/app_router.dart';
import 'package:fuel_tracker/core/services/validator.dart';
import 'package:fuel_tracker/features/auth/controllers/auth_controller.dart';
import 'package:fuel_tracker/features/widgets/app_name_widget.dart';
import 'package:fuel_tracker/features/widgets/custom_dropdown_field.dart';
import 'package:fuel_tracker/features/widgets/custom_text_field.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:remixicon/remixicon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _supabase = Supabase.instance.client;
  final authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  File? _imageFile;
  String? _selectedVehicleId;
  List<Map<String, dynamic>> _veiculosList = [];
  bool _carregandoVeiculos = true;

  @override
  void initState() {
    super.initState();
    authController.currentUser.value ??= UserModel();
    _carregarVeiculos();
  }

  final phoneFormatter = MaskTextInputFormatter(
    mask: '(##) # ####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _carregarVeiculos() async {
    try {
      final response = await _supabase
          .from('vehicles')
          .select('id, name, license_plate');
      setState(() {
        _veiculosList = List<Map<String, dynamic>>.from(response);

        _carregandoVeiculos = false;
      });
    } catch (e) {
      setState(() {
        _carregandoVeiculos = false;
      });
      debugPrint('Erro ao carregar veículos: $e');
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

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
                    SizedBox(height: 8.h),
                    Text(
                      'Crie sua conta para começar',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
                decoration: BorderRadius.vertical(
                  top: Radius.circular(45.r),
                ).toBoxDecoration(color: Colors.white),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 45.r,
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.1),
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : null,
                            child: _imageFile == null
                                ? Icon(
                                    RemixIcons.user_3_line,
                                    size: 40.r,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _mostrarOpcoes,
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.w,
                                  ),
                                ),
                                child: Icon(
                                  RemixIcons.camera_line,
                                  size: 16.r,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: nomeController,
                        icon: RemixIcons.user_3_line,
                        label: "lg_nome_completo".tr,
                        validator: nameValidator,
                        onSaved: (value) =>
                            authController.currentUser.value!.name = value,
                      ),
                      CustomTextField(
                        controller: emailController,
                        icon: RemixIcons.mail_line,
                        label: "lg_email".tr,
                        validator: emailValidator,
                        onSaved: (value) =>
                            authController.currentUser.value!.email = value,
                      ),
                      CustomTextField(
                        controller: phoneController,
                        icon: RemixIcons.cellphone_line,
                        label: "lg_telefone".tr,
                        textInputType: TextInputType.phone,
                        inputFormatters: [phoneFormatter],
                        validator: phoneValidator,
                        onSaved: (value) =>
                            authController.currentUser.value!.phone = value,
                      ),
                      CustomTextField(
                        controller: passwordController,
                        icon: RemixIcons.lock_password_line,
                        isSecret: true,
                        label: "lg_senha".tr,
                        validator: passwordValidator,
                        onSaved: (value) =>
                            authController.currentUser.value!.password = value,
                      ),
                      _carregandoVeiculos
                          ? const Center(child: CircularProgressIndicator())
                          : CustomDropdownField<String>(
                              icon: RemixIcons.car_line,
                              label: "Selecione o seu Veículo",
                              value: _selectedVehicleId,
                              items: _veiculosList.map((veiculo) {
                                return DropdownMenuItem<String>(
                                  value: veiculo['id'].toString(),
                                  child: Text(
                                    '${veiculo['name'] ?? ''} ${veiculo['license_plate'] ?? ''}',
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedVehicleId = value;
                                });
                              },
                              validator: (value) => value == null
                                  ? 'Por favor, selecione um veículo'
                                  : null,
                            ),
                      SizedBox(
                        height: 50.h,
                        child: GetX<AuthController>(
                          builder: (authController) {
                            return ElevatedButton(
                              onPressed: authController.isLoading.value
                                  ? null
                                  : () async {
                                      FocusScope.of(context).unfocus();
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                        authController
                                                .currentUser
                                                .value!
                                                .fileImage =
                                            _imageFile;
                                        bool success = await authController
                                            .signUpWithProfile(
                                              email: emailController.text
                                                  .trim(),
                                              password: passwordController.text,
                                              name: nomeController.text.trim(),
                                              phone: phoneController.text
                                                  .trim(),
                                              imageFile: _imageFile,
                                              vehicleId: _selectedVehicleId,
                                            );

                                        if (success) {
                                          Get.offAllNamed(
                                            PagesRoutes.splashRoute,
                                          );
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
                              child: authController.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      'lg_cadastrar'.tr,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                      // TextButton(
                      //   onPressed: authController.alternarEsqueciSenha,
                      //   child: Obx(
                      //     () => Text(
                      //       authController.isForgotPassword.value
                      //       ? "lg_voltar_login".tr
                      //       : "lg_forgot_password".tr,
                      //       style: TextStyle(
                      //         fontSize: 17.sp,
                      //         color: theme.colorScheme.onBackground.withOpacity(0.7),
                      //       ),
                      //     ),
                      //   ),
                      // ),
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

  void _mostrarOpcoes(){
    final theme = Theme.of(context);
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(RemixIcons.camera_line, color: theme.colorScheme.primary),
              title: Text('Tirar Foto com a Câmera'),
              onTap: (){
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(RemixIcons.image_line, color: theme.colorScheme.primary),
              title: Text('Escolher da Galeria'),
              onTap: (){
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
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
