import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/core/services/utils_service.dart';
import 'package:fuel_tracker/features/notification/controllers/notification_controller.dart';
import 'package:fuel_tracker/features/profile/controller/perfil_controller.dart';
import 'package:fuel_tracker/features/widgets/custom_text_field.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final PerfilController controller = Get.put(PerfilController());
  final notifController = Get.find<NotifController>();

  @override
  void initState() {
    super.initState();
    controller.loadUserProfile();
  }

  void _checkAndNotifyVehicleMaintenance() {
    if (notifController.maintenanceReminders.value) {
      final vehicleName = controller.vehicleName.value;
      if (vehicleName.isNotEmpty && vehicleName != 'N/A') {
        notifController.showNotification(
          id: 102,
          title: 'pf_notif_maint_title'.tr,
          body: 'pf_notif_maint_body'.trParams({'vehicle': vehicleName}),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerfilController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndNotifyVehicleMaintenance();
        });

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 60.h,
              pinned: true,
              elevation: 0,
              stretch: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsetsDirectional.only(
                  start: 50.w,
                  bottom: 16.h,
                ),
                centerTitle: false,
                title: Text(
                  "Meu Perfil",
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
                    _buildProfileHeader(theme, controller),
                    SizedBox(height: 32.h),
                    _buildSectionCard(
                      theme,
                      title: "Informações Pessoais",
                      child: Column(
                        children: [
                          _buildInfoRow(
                            theme,
                            "Nome",
                            controller.userName.value,
                          ),
                          _buildDivider(theme),
                          _buildInfoRow(
                            theme,
                            "E-mail",
                            controller.userEmail.value,
                          ),
                          _buildDivider(theme),
                          _buildInfoRow(
                            theme,
                            "Telemóvel",
                            controller.userPhone.value,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _buildSectionCard(
                      theme,
                      title: "Veículo Principal",
                      child: Column(
                        children: [
                          if (controller.vehicleImage.value.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: Image.network(
                                controller.vehicleImage.value,
                                height: 150.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                          _buildInfoRow(
                            theme,
                            "Nome",
                            controller.vehicleName.value,
                          ),
                          _buildDivider(theme),
                          _buildInfoRow(
                            theme,
                            "Matrícula",
                            controller.vehiclePlate.value,
                          ),
                          _buildDivider(theme),
                          _buildInfoRow(
                            theme,
                            "Combustível",
                            controller.vehicleFuelType.value,
                          ),
                          _buildDivider(theme),
                          _buildInfoRow(
                            theme,
                            "Capacidade de Depósito",
                            "${controller.vehicleTankCapacity.value} L",
                          ),
                          _buildDivider(theme),
                          _buildInfoRow(
                            theme,
                            "Odômetro Inicial",
                            "${controller.vehicleOdometer.value} km",
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _buildSectionCard(
                      theme,
                      title: "Definições da Conta",
                      child: Column(
                        children: [
                          _buildActionTile(
                            theme,
                            icon: RemixIcons.edit_box_line,
                            title: "Editar Perfil",
                            subtitle: "Atualizar dados pessoais e veículo",
                            onTap: () =>
                                _showEditProfileDialog(context, controller, theme),
                          ),
                          _buildDivider(theme),
                          _buildActionTile(
                            theme,
                            icon: RemixIcons.lock_password_line,
                            title: "Alterar Palavra-passe",
                            subtitle: "Modificar credenciais de acesso",
                            onTap: () =>
                                _showChangePasswordDialog(context, controller, theme),
                          ),
                          _buildDivider(theme),
                          _buildActionTile(
                            theme,
                            icon: RemixIcons.logout_box_r_line,
                            title: "Terminar Sessão",
                            subtitle: "Sair da conta atual",
                            isDestructive: true,
                            onTap: () => controller.signOut(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, PerfilController controller) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CircleAvatar(
                radius: 48.r,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage:
                    controller.userFoto.value.isNotEmpty &&
                        controller.userFoto.value != 'Sem Imagem'
                    ? NetworkImage(controller.userFoto.value)
                    : null,
                child:
                    controller.userFoto.value.isEmpty ||
                        controller.userFoto.value == 'Sem Imagem'
                    ? Icon(
                        RemixIcons.user_fill,
                        size: 45.r,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  RemixIcons.camera_line,
                  size: 14.sp,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          controller.userName.value.isNotEmpty
              ? controller.userName.value
              : "Utilizador",
          style: GoogleFonts.lexend(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "Membro desde ${controller.memberSince.value}",
          style: GoogleFonts.lexend(
            fontSize: 12.sp,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      color: theme.colorScheme.onSurface.withOpacity(0.05),
      height: 24.h,
    );
  }

  Widget _buildSectionCard(
    ThemeData theme, {
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 13.sp,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.lexend(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.redAccent : theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 20.r),
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
                      color: isDestructive
                          ? Colors.redAccent
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.lexend(
                      fontSize: 11.sp,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              RemixIcons.arrow_right_s_line,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    PerfilController controller,
    ThemeData theme,
  ) {
    final nameController = TextEditingController(
      text: controller.userName.value,
    );
    final phoneController = TextEditingController(
      text: controller.userPhone.value,
    );

    Get.defaultDialog(
      title: "Editar Perfil",
      titleStyle: GoogleFonts.lexend(
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
        color: theme.colorScheme.onSurface,
      ),
      backgroundColor: theme.colorScheme.surface,
      contentPadding: EdgeInsets.all(20.r),
      content: Column(
        children: [
          CustomTextField(
            controller: nameController,
            icon: RemixIcons.user_line,
            label: "Nome",
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            controller: phoneController,
            icon: RemixIcons.phone_line,
            label: "Telemóvel",
            // inputFormatters: [phoneValidator],
          ),
        ],
      ),
      textConfirm: "Salvar",
      textCancel: "Cancelar",
      confirmTextColor: theme.colorScheme.onPrimary,
      buttonColor: theme.colorScheme.primary,
      onConfirm: () async {
        await controller.updateProfile(
          nameController.text,
          phoneController.text,
        );
        Get.back();
      },
    );
  }

  void _showChangePasswordDialog(
    BuildContext context,
    PerfilController controller,
    ThemeData theme,
  ) {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final _utilsService = UtilsService();

    Get.defaultDialog(
      title: "Alterar Palavra-passe",
      titleStyle: GoogleFonts.lexend(
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
        color: theme.colorScheme.onSurface,
      ),
      backgroundColor: theme.colorScheme.surface,
      contentPadding: EdgeInsets.all(20.r),
      content: Column(
        children: [
          CustomTextField(
            controller: passwordController,
            isSecret: true,
            label: "Nova Palavra-passe",
            icon: RemixIcons.lock_password_line,
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            controller: confirmPasswordController,
            isSecret: true,
            label: "Confirmar Nova Palava-passe",
            icon: RemixIcons.lock_password_line,
          ),
        ],
      ),
      textConfirm: "Atualizar",
      textCancel: "Cancelar",
      confirmTextColor: theme.colorScheme.onPrimary,
      buttonColor: theme.colorScheme.primary,
      onConfirm: () async {
        final newPass = passwordController.text.trim();
        final confirmPass = confirmPasswordController.text.trim();

        if (newPass.isEmpty || confirmPass.isEmpty) {
          _utilsService.showToast(
            message: "Preencha todos os campos",
            isError: true,
          );
          return;
        }
        if (newPass.length < 7) {
          _utilsService.showToast(
            message: "A palavra-passe deve ter pelo menos 7 caracteres",
            isError: true,
          );
          return;
        }
        if (newPass != confirmPass) {
          _utilsService.showToast(
            message: "As palavras-passe não coincidem",
            isError: true,
          );
          return;
        }

        Get.back();
        await controller.updatePassword(newPass);
      },
    );
  }
}
