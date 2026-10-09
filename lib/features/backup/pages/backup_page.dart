import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuel_tracker/features/backup/controllers/backup_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class BackupPage extends GetView<BackupController> {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildBackupTile(
                  theme: theme,
                  icon: RemixIcons.file_pdf_line,
                  title: 'Exportar Backup em PDF',
                  subtitle:
                      'Gere um arquivo PDF com todos os seus dados. Você pode salvar no Google Drive ou enviar por e-mail.',
                  onTap: () => controller.exportBackupPDF(),
                ),
                _buildBackupTile(
                  theme: theme,
                  icon: RemixIcons.upload_cloud_line,
                  title: 'Exportar Backup',
                  subtitle:
                      'Gere um arquivo JSON com todos os seus dados. Você pode salvar no Google Drive ou enviar por e-mail.',
                  onTap: () => controller.exportBackup(),
                ),
                _buildBackupTile(
                  theme: theme,
                  icon: RemixIcons.download_cloud_line,
                  title: 'Restaurar Backup',
                  subtitle:
                      'Selecione um arquivo .json de backup gerado anteriormente para restaurar seu histórico no aplicativo.',
                  onTap: () => controller.importBackup(),
                ),
              ]),
            ),
          ),
          SliverPadding(padding: EdgeInsets.only(bottom: 32.h)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 60.h,
      pinned: true,
      floating: true,
      elevation: 0,
      backgroundColor:
          theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(start: 50.w, bottom: 16.h),
        title: Text(
          'Backup & Restauração',
          style: GoogleFonts.lexend(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildBackupTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.lexend(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: Icon(RemixIcons.arrow_right_s_line, color: Colors.grey[400]),
      ),
    );
  }
}
