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

class _ProfilePageState extends State<ProfilePage>{
  final PerfilController controller = Get.put(PerfilController());
  final notifController = Get.find<NotifController>();

  @override
  void initState() {
    super.initState();
    controller.loadUserProfile();
  }

  void _checkAndNotifyVehicleMaintenance(){
    if(notifController.maintenanceReminders.value){
      final vehicleName = controller.vehicleName.value;
      if(vehicleName.isNotEmpty && vehicleName != 'N/A'){
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

        WidgetsBinding.instance.addPostFrameCallback((_){
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
              backgroundColor:
                  theme.appBarTheme.backgroundColor ??
                  theme.scaffoldBackgroundColor,
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
                          _buildInfoRow("Nome", controller.userName.value),
                          Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 24.h,
                          ),
                          _buildInfoRow("E-mail", controller.userEmail.value),
                          Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 24.h,
                          ),
                          _buildInfoRow(
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
                          if(controller.vehicleImage.value.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.network(
                                controller.vehicleImage.value,
                                height: 140.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                          _buildInfoRow("Nome", controller.vehicleName.value),
                          Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 24.h,
                          ),
                          _buildInfoRow(
                            "Matrícula",
                            controller.vehiclePlate.value,
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 24.h,
                          ),
                          _buildInfoRow(
                            "Combustível",
                            controller.vehicleFuelType.value,
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 24.h,
                          ),
                          _buildInfoRow(
                            "Capacidade de Depósito",
                            "${controller.vehicleTankCapacity.value} L",
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 24.h,
                          ),                          
                          _buildInfoRow(
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
                            icon: RemixIcons.edit_box_line,
                            title: "Editar Perfil",
                            subtitle: "Atualizar dados pessoais e veículo",
                            onTap: () => _showEditProfileDialog(context, controller),
                            theme: theme,
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 24.h,
                          ),
                          _buildActionTile(
                            icon: RemixIcons.lock_password_line,
                            title: "Alterar Palavra-passe",
                            subtitle: "Modificar credenciais de acesso",
                            onTap: () => _showChangePasswordDialog(context, controller),
                            theme: theme,
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 24.h,
                          ),
                          _buildActionTile(
                            icon: RemixIcons.logout_box_r_line,
                            title: "Terminar Sessão",
                            subtitle: "Sair da conta atual",
                            isDestructive: true,
                            onTap: () => controller.signOut(),
                            theme: theme,
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
                radius: 45.r,
                backgroundColor: Color(0xFF1E1E1E),
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
                        color: Colors.white70,
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
                  border: Border.all(color: Color(0xFF121212), width: 2),
                ),
                child: Icon(
                  RemixIcons.camera_line,
                  size: 14.sp,
                  color: Colors.white,
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
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "Membro desde ${controller.memberSince.value}",
          style: GoogleFonts.lexend(fontSize: 12.sp, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    ThemeData theme, {
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
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
          SizedBox(height: 16.h),
          child,
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
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.redAccent : theme.colorScheme.primary;

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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
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
                      color: isDestructive ? Colors.redAccent : Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
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

  void _showEditProfileDialog(BuildContext context, PerfilController controller){
    final nameController = TextEditingController(text: controller.userName.value);
    final phoneController = TextEditingController(text: controller.userPhone.value);

    Get.defaultDialog(
      title: "Editar Perfil",
      titleStyle: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 16.sp),
      backgroundColor: Color(0xFF1E1E1E),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          children: [
            CustomTextField(
              controller: nameController,
              icon: RemixIcons.user_line,
              label: "Nome",
            ),
            CustomTextField(
              controller: phoneController,
              icon: RemixIcons.phone_line,
              label: "Telemóvel",
              // inputFormatters: [phoneValidator],
            ),
          ],
        ),
      ),
      textConfirm: "Salvar",
      textCancel: "Cancelar",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await controller.updateProfile(nameController.text, phoneController.text);
        Get.back();
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context, PerfilController controller){
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final _utilsService = UtilsService();
    
    Get.defaultDialog(
      title: "Alterar Palavra-passe",
      titleStyle: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.white),
      backgroundColor: Color(0xFF1E1E1E),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          children: [
            CustomTextField(
              controller: passwordController,
              isSecret: true,
              label: "Nova Palavra-passe",
              icon: RemixIcons.lock_password_line,
            ),
            CustomTextField(
              controller: confirmPasswordController,
              isSecret: true,
              label: "Confirmar Nova Palava-passe",
              icon: RemixIcons.lock_password_line,
            ),
          ],
        ),
      ),
      textConfirm: "Atualizar",
      textCancel: "Cancelar",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        final newPass = passwordController.text.trim();
        final confirmPass = confirmPasswordController.text.trim();
        
        if(newPass.isEmpty || confirmPass.isEmpty){
          _utilsService.showToast(message: "Preencha todos os campos", isError: true);
          return;
        }
        if(newPass.length < 7){
          _utilsService.showToast(message: "A palavra-passe deve ter pelo menos 7 caracteres", isError: true);
          return;
        }
        if(newPass != confirmPass){
          _utilsService.showToast(message: "As palavras-passe não coincidem", isError: true);
          return;
        }

        Get.back();
        await controller.updatePassword(newPass);
      },
    );
  }
}
